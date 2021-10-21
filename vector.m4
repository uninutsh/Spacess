struct Vector_int
{
  size_t capacity;
  size_t size;
  int *array;
};

void
Vector_int_free (struct Vector_int *vector)
{
  free(vector->array);
}

void
Vector_int_push (struct Vector_int *vector, int object)
{
  if (vector->size == vector->capacity)
   {
      vector->capacity *= 2;
      vector->array = realloc(vector->array, vector->capacity * sizeof(int));
      fprintf (stdout, "double capacity = %li\n", vector->capacity);
   }
   vector->array[vector->size] = object;
   vector->size++;
}

void
Vector_int_with_capacity (struct Vector_int *vector, size_t capacity)
{
  vector->capacity = capacity;
  vector->size = 0;
  vector->array = calloc(capacity, sizeof(int));
}

void
Vector_int_initialize (struct Vector_int *vector)
{
  Vector_int_with_capacity (vector, 1);
}