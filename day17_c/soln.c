#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SHAPE_START_OFF 2
#define MAX(a,b) ((a) > (b) ? (a) : (b))

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
static Shape SHAPES[NUM_SHAPES] = {
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

#define MAX_N 1000000
char str[MAX_N + 1];
int sa[MAX_N], rank[MAX_N], tmp[MAX_N], height[MAX_N];

void get_sa(int n) {
  for (int i = 0; i <= n; ++i) {
    rank[i] = str[i];
  }
  for (int k = 1; k <= n; k <<= 1) {
    for (int i = 0; i <= n; ++i) {
      tmp[i] = rank[i];
      rank[i] = 0;
    }
    for (int i = 0; i <= n; ++i) {
      ++rank[tmp[i]];
    }
    for (int i = 1; i <= n; ++i) {
      rank[i] += rank[i - 1];
    }
    for (int i = n; i >= 0; --i) {
      if (sa[i] - k >= 0) {
        tmp[--rank[tmp[sa[i] - k]]] = sa[i] - k;
      }
    }
    for (int i = 0; i <= n; ++i) {
      tmp[i] = rank[i];
      rank[i] = 0;
    }
    for (int i = 0; i <= n; ++i) {
      ++rank[tmp[i]];
    }
    for (int i = 1; i <= n; ++i) {
      rank[i] += rank[i - 1];
    }
    for (int i = n; i >= 0; --i) {
      sa[--rank[tmp[sa[i]]]] = tmp[sa[i]];
    }
  }
}

void get_height(int n) {
  for (int i = 0; i <= n; ++i) {
    rank[sa[i]] = i;
  }
  int h = 0;
  for (int i = 0; i < n; ++i) {
    if (rank[i] > 0) {
      int j = sa[rank[i] - 1];
      while (str[i + h] == str[j + h]) {
        ++h;
      }
      height[rank[i]] = h;
      if (h > 0) {
        --h;
      }
    }
  }
}


void reverse_shapes_y() {
  for (int i = 0; i < NUM_SHAPES; i++) {
    Shape *shape = (Shape *)&SHAPES[i];
    char lines[4] = {0};
    for (int y = 0; y < shape->height; y++) {
      lines[y] = shape->lines[shape->height - y - 1];
    }
    for (int y = 0; y < shape->height; y++) {
      shape->lines[y] = lines[y];
    }
  }
}

Shape shape_try_rshift(const Shape old_shape, const int falling_bot, const int num_shifts) {
  Shape new_shape = old_shape;
  for (int y = 0; y < old_shape.height; y++) {
    char playfield_row = 0;
    if (falling_bot >= 0)
      playfield_row = PLAYFIELD[falling_bot+y];
    for (int s = 0; s < num_shifts; s++) {
      if (((playfield_row << 1) | 0b1) & old_shape.lines[y]) {
        return old_shape;
      }
      new_shape.lines[y] >>= 1;
    }
  }
  return new_shape;
}

#define PLAYFIELD_RIGHT_EDGE 6
Shape shape_try_lshift(Shape old_shape, int falling_bot, int num_shifts) {
  Shape new_shape = old_shape;
  for (int y = 0; y < old_shape.height; y++) {
    char playfield_row = 0;
    if (falling_bot >= 0) {
      playfield_row = PLAYFIELD[falling_bot+y];
    }
    for (int s = 0; s < num_shifts; s++) {
      if (((playfield_row >> 1) | (1 << PLAYFIELD_RIGHT_EDGE)) & new_shape.lines[y])
        return old_shape;
      new_shape.lines[y] <<= 1;
    }
  }
  return new_shape;
}

int add_new_piece(Shape shape, int max_rock_height) {
#define DIST_FROM_MAX_HEIGHT_FOR_NEW_PIECE 3
  return max_rock_height + DIST_FROM_MAX_HEIGHT_FOR_NEW_PIECE;
}

void add_playfield(Shape shape, int falling_bot) {
  for (int y = 0; y < shape.height; y++) {
    char intersection = PLAYFIELD[falling_bot+y] & shape.lines[y];
    assert(intersection == 0);
    PLAYFIELD[falling_bot + y] |= shape.lines[y];
  }
}

bool shape_should_come_to_rest(Shape shape, int falling_bot) {
  assert(falling_bot >= 0);

  if (falling_bot == 0) return true;
  int down_by_one = falling_bot - 1;
  for (int y = 0; y < shape.height; y++)
    if (PLAYFIELD[down_by_one + y] & shape.lines[y]) return true;
  return false;
}

void print(int lo) {
  for (int i = lo; i >= 0; i--) {
    char row = PLAYFIELD[i];
    for (int j = PLAYFIELD_RIGHT_EDGE; j >= 0; j--) {
      printf("%c", (1 << j) & row ? '@' : '.');
    }
    printf("\n");
  }
}

void print_s(int top_y, Shape falling_shape, int falling_bot) {
  char c;
  for (int y = top_y; y >= 0; y--) {
    char playrow = PLAYFIELD[y];
    char shaperow = 0;
    if(y >= falling_bot && y < falling_bot+falling_shape.height) {
      shaperow = falling_shape.lines[y - falling_bot];
    }
    for (int x = PLAYFIELD_RIGHT_EDGE; x >= 0; x--) {
      bool matches_playfield = (1 << x) & playrow;
      bool matches_falling = (1 << x) & shaperow;
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

#define DBG dbg_field(max_rock_height, falling_shape, falling_bot)
#define NEW_SHAPE  {\
  DBG;\
}

int main() {
  reverse_shapes_y();

  FILE  *f = fopen("input.txt", "r");
  char c;
  int max_rock_height = 0;
  int num_rocks = 0;
  Shape falling_shape = SHAPES[num_rocks++ % NUM_SHAPES];\
  falling_shape = shape_try_rshift(falling_shape, -1, SHAPE_START_OFF);
  int falling_bot = add_new_piece(falling_shape, max_rock_height);

  while (num_rocks < 2023) { // loop for a single turn:
    // step 1: shift the piece < or >
    switch ((c = (char) getc(f))) {
      case '<':
        falling_shape = shape_try_lshift(falling_shape, falling_bot, 1);
        break;
      case '>':
        falling_shape = shape_try_rshift(falling_shape, falling_bot, 1);
        break;
      case '\n':
      case EOF:
        rewind(f);
        //printf("num_rocks fallen: %d, max_height: %d\n", num_rocks, max_rock_height);
        continue;
      default:
        printf("unexpected char: |%c|\n", c);
        exit(1);
    }

    // step 2: fall down by 1 square
    if (shape_should_come_to_rest(falling_shape, falling_bot)) {
      add_playfield(falling_shape, falling_bot);
      max_rock_height = MAX(max_rock_height, falling_bot + falling_shape.height);
      falling_shape = SHAPES[num_rocks++ % NUM_SHAPES];
      falling_shape = shape_try_rshift(falling_shape, -1, SHAPE_START_OFF);
      falling_bot = add_new_piece(falling_shape, max_rock_height);
    } else {
      falling_bot--;
    }
  }

  int n = max_rock_height;
  char *s = PLAYFIELD;
  get_sa(n);
  get_height(n);

  int lrs = 0;
  for (int i = 1; i <= n; ++i) {
    lrs = MAX(lrs, height[i]);
  }
  printf("Longest repeated substring: %d\n", lrs);

  //  print(10);
  //printf("part 1: %d\n", max_rock_height);
}
