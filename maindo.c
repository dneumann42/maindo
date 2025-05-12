#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#define VALUE_TYPE                                                             \
  X(NOTHING)                                                                   \
  X(BOOLEAN)                                                                   \
  X(NUMBER)                                                                    \
  X(STRING)                                                                    \
  X(SYMBOL)                                                                    \
  X(CONS)
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

static Mdo_allocator __allocator =
    (Mdo_allocator){.new = Mdo_new, .del = Mdo_del};

void Mdo_set_allocator(Mdo_allocator new_allocator) {
  __allocator = new_allocator;
}

void *new(size_t size) { return __allocator.new(size); }
void del(void *ptr) { __allocator.del(ptr); }

Mdo_value *ref(Mdo_value *v) {
  v->refc += 1;
  return v;
}

void unref(Mdo_value *v) {
  v->refc -= 1;
  if (v->refc <= 0) {
    del(v);
  }
}

Mdo_value *new_init(Mdo_value v) {
  Mdo_value *value = new (sizeof(Mdo_value));
  *value = v;
  return ref(value);
}

Mdo_value *new_value() { return ref(new (sizeof(Mdo_value))); }

#define num(n) new_init((Mdo_value){.type = NUMBER, .number = n})
#define boolean(t) new_init((Mdo_value){.type = BOOLEAN, .boolean = t})

int main(void) {
  Mdo_value *n = num(3.1415926 * 2.0);
  printf("%f\n", n->number);
}
