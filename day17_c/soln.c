#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>


#define SHAPE_START_RSHIFT 2

typedef struct Shape {
  short height;
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
  {.height = 1, .lines = {0b1111000}},
  {.height = 3, .lines = {0b0100000,
                             0b1110000,
                             0b0100000}},
  {.height = 3, .lines = {0b0010000,
                             0b0010000,
                             0b1110000}},
  {.height = 4, .lines = {0b1000000,
                             0b1000000,
                             0b1000000,
                             0b1000000}},
  {.height = 2, .lines = {0b1100000,
                             0b1100000}},
};

Shape shape_try_rshift(Shape shape, char falling_bot, int num_shifts) {
  printf("rshifting %d times\n", num_shifts);
  Shape new_shape = shape;
  for (int i = 0; i < shape.height; i++) {
    char playfield_row = 0;
    if (falling_bot >= 0) {
      playfield_row = PLAYFIELD[falling_bot+i];
    }
    printf("shifting right, checking playfield index %d\n", falling_bot+i);
    for (int s = 0; s < num_shifts; s++) {
      if (((playfield_row << 1) | 0b1) & new_shape.lines[i]) {
        return shape;
      }
      printf("actually doing rshift once during s=0\n");
      new_shape.lines[i] >>= 1;
    }
    shape = new_shape;
  }
  return new_shape;
}

Shape shape_try_lshift(Shape shape, char falling_bot, int num_shifts) {
  printf("lshifting %d times\n", num_shifts);
  Shape new_shape = shape;
  for (int i = 0; i < shape.height; i++) {
    char playfield_row = 0;
    if (falling_bot >= 0) {
      playfield_row = PLAYFIELD[falling_bot+i];
    }
    printf("shifting right, checking playfield index %d\n", falling_bot+i);
    for (int s = 0; s < num_shifts; s++) {
      if (((playfield_row >> 1) | (1 << 6)) & new_shape.lines[i]) return shape;
      printf("actually doing lshift once\n");
      new_shape.lines[i] <<= 1;
    }
  }
  return new_shape;
}

int add_new_piece(Shape shape, int max_rock_height) {
#define DIST_FROM_MAX_HEIGHT_FOR_NEW_PIECE 3
  return max_rock_height + DIST_FROM_MAX_HEIGHT_FOR_NEW_PIECE;
}

void add_playfield(Shape shape, int bottom_i) {
  int height = shape.height;
  for (int i = 0; i < shape.height; i++) {
    PLAYFIELD[bottom_i+i] |= shape.lines[--height];
  }
  printf("add_playfield height: %d\n", shape.height);
}

bool piece_can_fall(Shape shape, int falling_bot) {
  printf("checking piece_can_fall at falling_bot %d\n", falling_bot);

  if (falling_bot <= 0) return false;
  falling_bot--;
  for (int i = 0; i < shape.height; i++) 
    if (PLAYFIELD[falling_bot+i] & shape.lines[--shape.height]) return false;
  return true;
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

void print_s(int lo, Shape falling_shape, int bottom_i) {
  char c;
  for (int i = lo; i >= 0; i--) {
    char row = PLAYFIELD[i];
    char row2 = 0;
    if(i > bottom_i && i <= bottom_i+falling_shape.height) {
      row2 = falling_shape.lines[bottom_i+falling_shape.height-i];
    }
    for (int j = 6; j >= 0; j--) {
      bool matches_playfield = (1 << j) & row;
      bool matches_falling = (1 << j) & row2;
      if (matches_falling && matches_playfield) {
        c = '*';
      } else if (matches_playfield) {
        c = '#';
      } else if (matches_falling) {
        c = '@';
      } else {
        c = '.';
      }
      printf("%c", c);
    }
    printf("\n");
  }
}

void dbg_field(int max_rock_height, Shape falling_shape, int falling_bot) {
      printf("-----------------\n");
      print_s(max_rock_height+5, falling_shape, falling_bot);
      printf("-----------------\n");
}
 
int main() {
  FILE  *f = fopen("sample.txt", "r");
  char c;
  int max_rock_height = 0;
  int next_shape_type = 0;
  int falling_bot = -1;
  Shape falling_shape;

  for (int num_iterations = 2022; num_iterations > 0;
       num_iterations--) {
    falling_shape = shape_try_rshift(
        SHAPES[next_shape_type],
        falling_bot,
        SHAPE_START_RSHIFT);
    next_shape_type = ++next_shape_type % NUM_SHAPES;
    falling_bot = add_new_piece(falling_shape, max_rock_height);
    while (true) { // loop for a single turn:
      // step 1: shift the piece < or >
      switch ((c = getc(f))) {
        case '<':
          falling_shape = shape_try_lshift(falling_shape, falling_bot, 1);
          break;
        case '>':
          falling_shape = shape_try_rshift(falling_shape, falling_bot, 1);
          break;
        case '\n':
        case EOF:
          rewind(f);
          continue;
        default:
          printf("unexpected char: |%c|\n", c);
          exit(1);
      }

      // step 2: fall down by 1 square
      if (!piece_can_fall(falling_shape, falling_bot)) break;
      falling_bot--;

      dbg_field(max_rock_height, falling_shape, falling_bot);
    }

    add_playfield(falling_shape, falling_bot);
    max_rock_height = falling_bot + falling_shape.height;
  }

done:
  print(10);
  printf("part 1: %d\n", falling_bot+falling_shape.height);
}
