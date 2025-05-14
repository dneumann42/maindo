#include <ctype.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define VALUE_TYPE                                                             \
  X(NOTHING)                                                                   \
  X(BOOLEAN)                                                                   \
  X(NUMBER)                                                                    \
  X(STRING)                                                                    \
  X(SYMBOL)                                                                    \
  X(CONS)                                                                      \
  X(DO)
enum Mdo_ValueType {
#define X(s) s,
  VALUE_TYPE
#undef X
};
static const char *Mdo_ValueType_repr[] = {
#define X(s) #s,
    VALUE_TYPE
#undef X
};
#undef VALUE_TYPE

enum Mdo_ReaderError {
  READER_ERROR_NONE,
  READER_ERROR_INVALID_VALUE,
  READER_ERROR_INVALID_NUMBER,
  READER_ERROR_INVALID_SYMBOL,
};

typedef struct Mdo_str_t {
  size_t len;
  char *data;
} Mdo_str;

typedef struct Mdo_value_t {
  int16_t type;
  int16_t refc;
  union {
    double number;
    bool boolean;
    Mdo_str string;
    Mdo_str symbol;
    struct {
      struct Mdo_value_t *car;
      struct Mdo_value_t *cdr;
    };
  };
} Mdo_value;

typedef struct Mdo_allocator_t {
  void *(*new)(size_t);
  void (*del)(void *);
} Mdo_allocator;

void *Mdo_new(size_t size) { return malloc(size); }

void Mdo_del(void *ptr) { free(ptr); }

void *new(Mdo_allocator alloc, size_t size) { return alloc.new(size); }
void del(Mdo_allocator alloc, void *ptr) { alloc.del(ptr); }

Mdo_value *ref(Mdo_value *v) {
  v->refc += 1;
  return v;
}

void deinit(Mdo_allocator alloc, Mdo_value *v);

void unref(Mdo_allocator alloc, Mdo_value *v) {
  v->refc -= 1;
  if (v->refc <= 0) {
    deinit(alloc, v);
  }
}

void deinit(Mdo_allocator alloc, Mdo_value *v) {
  if (v->type == STRING) {
    free(v->string.data);
  }
  if (v->type == CONS) {
    Mdo_value *it = v;
    while (it != NULL) {
      if (it->car) {
        unref(alloc, it->car);
      }
      it = it->cdr;
    }
  }
  alloc.del(v);
}

Mdo_value *new_init(Mdo_allocator alloc, Mdo_value v) {
  Mdo_value *value = alloc.new(sizeof(Mdo_value));
  *value = v;
  return ref(value);
}

Mdo_value *new_value(Mdo_allocator alloc) {
  return ref(alloc.new(sizeof(Mdo_value)));
}

#define num(n) new_init(alloc, (Mdo_value){.type = NUMBER, .number = n})
#define boolean(t) new_init(alloc, (Mdo_value){.type = BOOLEAN, .boolean = t})

Mdo_str new_str_s(const char *cstr) {
  Mdo_str str = {};
  str.len = strlen(cstr);
  str.data = malloc(str.len);
  memcpy(str.data, cstr, str.len);
  return str;
}

Mdo_str new_str(size_t len) {
  Mdo_str str = {};
  str.len = len;
  str.data = malloc(str.len);
  return str;
}

typedef struct Mdo_reader_t {
  Mdo_allocator alloc;
  size_t cursor;
  int error;
} Mdo_reader;

Mdo_reader mdo_init_reader(Mdo_allocator alloc) {
  return (Mdo_reader){.alloc = alloc, .cursor = 0, .error = 0};
}

#define TRY_PARSE(R, C, F)                                                     \
  do {                                                                         \
    Mdo_value *r = (F)((R), (C));                                              \
    if (reader->error != 0)                                                    \
      return NULL;                                                             \
    if (r != NULL)                                                             \
      return r;                                                                \
  } while (0)

char *to_str_rec(Mdo_value *v, int depth) {
  static int page = 0;
  static char pages[512][2048] = {0};
  char *buff = pages[page++ % 256];

  switch (v->type) {
  case NOTHING:
    return "Nothing";
  case CONS:
  case DO: {
    int cursor = 0;
    if (v->type == DO) {
      buff[cursor++] = '(';
      buff[cursor++] = 'd';
      buff[cursor++] = 'o';
      buff[cursor++] = ' ';
    } else {
      buff[cursor++] = '(';
    }
    Mdo_value *it = v;
    while (it != NULL) {
      char *sub = to_str_rec(it->car, depth + 1);
      for (size_t i = 0; i < strlen(sub); i++)
        buff[cursor++] = sub[i];
      it = it->cdr;
      if (it != NULL)
        buff[cursor++] = ' ';
    }
    buff[cursor++] = ')';
    buff[cursor] = 0;
    return buff;
  }
  case BOOLEAN:
    return v->boolean ? "T" : "F";
  case NUMBER:
    sprintf(buff, "%f", v->number);
    return buff;
  case SYMBOL:
    sprintf(buff, "%.*s", (int)v->string.len, v->string.data);
    return buff;
  case STRING:
    sprintf(buff, "'%.*s'", (int)v->string.len, v->string.data);
    return buff;
  }
  return buff;
}

Mdo_value *cons(Mdo_allocator alloc, Mdo_value *car, Mdo_value *cdr, int type) {
  return new_init(alloc, (Mdo_value){.type = type, .car = car, .cdr = cdr});
}

Mdo_value *reversed(Mdo_value *list) {
  Mdo_value *prev = NULL;
  Mdo_value *curr = list;
  while (curr != NULL && (curr->type == DO || curr->type == CONS)) {
    Mdo_value *next = curr->cdr;
    curr->cdr = prev;
    prev = curr;
    curr = next;
  }
  return prev;
}

bool at_eof(Mdo_reader *r, Mdo_str code) { return r->cursor >= code.len; }
char chr(Mdo_reader *r, Mdo_str code) { return (*(code.data + r->cursor)); }
bool at_chr(Mdo_reader *r, Mdo_str code, char compare) {
  return chr(r, code) == compare;
}
void skip_ws(Mdo_reader *r, Mdo_str code) {
  while (isspace(chr(r, code)))
    r->cursor += 1;
}

Mdo_value *mdo_read_expression(Mdo_reader *reader, Mdo_str code);
Mdo_value *mdo_read_code(Mdo_reader *reader, Mdo_str code) {
  Mdo_value *program = NULL;
  while (!at_eof(reader, code)) {
    Mdo_value *expr = mdo_read_expression(reader, code);
    program = cons(reader->alloc, expr, program, DO);
    skip_ws(reader, code);
  }
  return reversed(program);
}

Mdo_value *mdo_read_command(Mdo_reader *reader, Mdo_str code);
Mdo_value *mdo_read_call(Mdo_reader *reader, Mdo_str code);
Mdo_value *mdo_read_expression(Mdo_reader *reader, Mdo_str code) {
  // TRY_PARSE(reader, code, mdo_read_command);
  TRY_PARSE(reader, code, mdo_read_call);
  return NULL;
}

Mdo_value *mdo_read_sequence(Mdo_reader *reader, Mdo_str code, int type);
Mdo_value *mdo_read_value(Mdo_reader *reader, Mdo_str code);
Mdo_value *mdo_read_call(Mdo_reader *reader, Mdo_str code) {
  Mdo_value *seq = mdo_read_sequence(reader, code, CONS);
  return seq ? seq : mdo_read_value(reader, code);
}

Mdo_value *mdo_read_command(Mdo_reader *reader, Mdo_str code) {
  skip_ws(reader, code);
  reader->error = 1;
  return NULL;
}

Mdo_value *mdo_read_sequence(Mdo_reader *reader, Mdo_str code, int type) {
  skip_ws(reader, code);
  if (!at_chr(reader, code, '('))
    return NULL;
  reader->cursor += 1;
  Mdo_value *list = NULL;
  while (!at_eof(reader, code)) {
    skip_ws(reader, code);
    if (at_chr(reader, code, ')')) {
      reader->cursor += 1;
      break;
    }
    Mdo_value *exp = mdo_read_expression(reader, code);
    list = cons(reader->alloc, exp, list, type);
  }
  return reversed(list);
}

Mdo_value *mdo_read_symbol(Mdo_reader *reader, Mdo_str code);
Mdo_value *mdo_read_number(Mdo_reader *reader, Mdo_str code);
Mdo_value *mdo_read_value(Mdo_reader *reader, Mdo_str code) {
  TRY_PARSE(reader, code, mdo_read_number);
  TRY_PARSE(reader, code, mdo_read_symbol);
  reader->error = READER_ERROR_INVALID_VALUE;
  return NULL;
}

Mdo_value *mdo_read_number(Mdo_reader *reader, Mdo_str code) {
  if (!isdigit(chr(reader, code)))
    return NULL;
  size_t start = reader->cursor;
  while (!at_eof(reader, code) && isdigit(chr(reader, code)))
    reader->cursor += 1;
  if (start == reader->cursor) {
    reader->error = READER_ERROR_INVALID_NUMBER;
    return NULL;
  }
  char cstr[128];
  sprintf(cstr, "%.*s", (int)(reader->cursor - start), code.data + start);
  return new_init(reader->alloc, (Mdo_value){
                                     .type = NUMBER,
                                     .number = atof(cstr),
                                 });
}

bool is_special(char chr) {
  switch (chr) {
  case ',':
  case ':':
  case '[':
  case ']':
  case '{':
  case '}':
  case ')':
  case '(':
    return true;
  }
  return false;
}

Mdo_value *mdo_read_symbol(Mdo_reader *reader, Mdo_str code) {
  skip_ws(reader, code);
  size_t start = reader->cursor;
  while (!at_eof(reader, code) && !isspace(chr(reader, code)) &&
         !is_special(chr(reader, code))) {
    reader->cursor += 1;
  }
  if (reader->cursor == start) {
    reader->error = READER_ERROR_INVALID_SYMBOL;
    return NULL;
  }
  Mdo_str symbol = new_str(reader->cursor - start);
  for (int i = 0; (start + i) < reader->cursor; i++) {
    symbol.data[i] = code.data[start + i];
  }
  return new_init(reader->alloc, (Mdo_value){.type = SYMBOL, .symbol = symbol});
}

int main(void) {
  Mdo_allocator alloc = (Mdo_allocator){
      .new = Mdo_new,
      .del = Mdo_del,
  };
  Mdo_str code = new_str_s("(+ 1 (/ 2 4) 3)");
  Mdo_reader reader = mdo_init_reader(alloc);
  Mdo_value *program = mdo_read_code(&reader, code);
  printf("-> %s\n", to_str_rec(program, 0));
}
