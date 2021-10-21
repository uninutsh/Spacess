changequote([[, ]])dnl
define(Vector, [[Vector_$1]])
define(define_Vector,
typedef struct Vector_$1
{
  size_t capacity;
  size_t size;
  $1 *array;
} Vector_$1;

void
Vector_$1_free (struct Vector_$1 *vector)
{
  free(vector->array);
}

void
Vector_$1_push (struct Vector_$1 *vector, $1 object)
{
  if (vector->size == vector->capacity)
   {
      vector->capacity *= 2;
      vector->array = realloc(vector->array, vector->capacity * sizeof($1));
      fprintf (stdout, "double capacity = %li\n", vector->capacity);
   }
   vector->array[vector->size] = object;
   vector->size++;
}

void
Vector_$1_with_capacity (struct Vector_$1 *vector, size_t capacity)
{
  vector->capacity = capacity;
  vector->size = 0;
  vector->array = calloc(capacity, sizeof($1));
}

void
Vector_$1_initialize (struct Vector_$1 *vector)
{
  Vector_$1_with_capacity (vector, 1);
}
)dnl
define(Vector_foreach,

)dnl
#include <stdlib.h>
#include <stdio.h>

define_Vector([[int]])
define_Vector([[double]])

int
main (int argc, char *argv[])
{
  fprintf (stdout, "Vector_int\n\n");
  Vector(int) v;

  Vector(int)_initialize (&v);
  for (int i = 0; i < 16; i++)
    {
      Vector_int_push (&v, i);
    }
  for (size_t i = 0; i < v.size; i++)
    {
      fprintf (stdout, "v[%li] = %i\n", i,v.array[i]);
    }
  Vector_int_free (&v);
  fprintf (stdout, "\n\n");
  fprintf (stdout, "Vector_double\n\n");
  struct Vector_double w;
  Vector_double_initialize (&w);
  for (double i = 0; i < 16; i++)
    {
      Vector_double_push (&w, i + 0.5);
    }
  for (size_t i = 0; i < w.size; i++)
    {
      fprintf (stdout, "w[%li] = %lf\n", i,w.array[i]);
    }
  Vector_double_free (&w);
  fprintf (stdout, "\n\n");
  return 0;
}