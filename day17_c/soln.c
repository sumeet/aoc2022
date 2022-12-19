#include <stdio.h>

#define SHAPE_START_RSHIFT 2

typedef struct Shape {
  short num_lines;
  char lines[4];
} Shape;

// just alloc a gig up front
#define MAX_HEIGHT 1000000000
char PLAYFIELD[MAX_HEIGHT] = {0};

// |..@@@@.| PLAYFIELD[i]: 3
// |.......| PLAYFIELD[i]: 2
// |.......| PLAYFIELD[i]: 1
// |.......| PLAYFIELD[i]: 0
// +-------+


#define NUM_SHAPES 5
static const Shape SHAPES[NUM_SHAPES] = {
  {.num_lines = 1, .lines = {0b1111000}},
  {.num_lines = 3, .lines = {0b0100000,
                             0b1110000,
                             0b0100000}},
  {.num_lines = 3, .lines = {0b0010000,
                             0b0010000,
                             0b1110000}},
  {.num_lines = 4, .lines = {0b1000000,
                             0b1000000,
                             0b1000000,
                             0b1000000}},
  {.num_lines = 2, .lines = {0b1100000,
                             0b1100000}},
};

void try_rshift(Shape shape, int bot_index, int num_shifts) {
  for (int i = 0; i < shape.num_lines; i++) {
    if (0b1 & PLAYFIELD[bot_index+i]) return;
    shape.lines[i] >>= num_shifts;
  }
  for (int i = bot_index; i < bot_index+shape.num_lines; i++) {
    PLAYFIELD[i] = shape.lines[--shape.num_lines];
  }
}

Shape shape_try_lshift(Shape shape, int num_shifts) {
  Shape new_shape = shape;
  for (int i = 0; i < shape.num_lines; i++) {
    if ((1 << 6) & shape.lines[i]) return shape;
    new_shape.lines[i] <<= num_shifts;
  }
  return new_shape;
}

int add_playfield(Shape shape, int lowest_rock_i) {
#define DIST_FROM_BOT 3
  int lo = lowest_rock_i + DIST_FROM_BOT;
  for (int i = lo + shape.num_lines; i > lo; i--) {
    PLAYFIELD[--i] = shape.lines[--shape.num_lines];
  }
  return lo;
}

void print(int lo) {
  for (int i = lo; i >= 0; i--) {
    char row = PLAYFIELD[i];
    for (int j = 6; j >= 0; j--) {
      printf("%c", (1 << j) & row ? '@' : '.');
    }
    printf("\n");
  }
}
 
int main() {
  FILE  *f = fopen("input.txt", "r");
  char c;
  int lowest_rock_i = 0;

  int next_shape_type = 0;
  Shape falling_shape = SHAPES[next_shape_type];
  next_shape_type = ++next_shape_type % NUM_SHAPES;
  int falling_bot = add_playfield(falling_shape, lowest_rock_i);
  try_rshift(falling_shape, falling_bot, 2);
  do {
    c = getc(f);
    switch (c) {
      case '<': 
        break;
    }
  } while (0);
  print(5);

  //while ((c = getc(f)) != EOF) {
  //  // til this shape hits something
  //  while() {
  //  }
  //}
done:
  printf("part 1:\n");
}
