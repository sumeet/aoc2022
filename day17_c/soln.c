#include <assert.h>
#include <limits.h>
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

  // Function to find the longest repeating subsequence
  // that appears twice in the given string
int findLongestRepeatingSubSeq(char *str) {
  int n = strlen(str);

  // Create and initialize DP table
  int **dp = malloc((n + 1) * sizeof(int *));
  for (int i = 0; i <= n; i++) {
    dp[i] = malloc((n + 1) * sizeof(int));
  }
  for (int i = 0; i <= n; i++) {
    for (int j = 0; j <= n; j++) {
      dp[i][j] = 0;
    }
  }

  // Fill dp table (similar to LCS loops)
  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= n; j++) {
      // If characters match and indexes are
      // not same
      if (str[i - 1] == str[j - 1] && i != j) {
        dp[i][j] = 1 + dp[i - 1][j - 1];
      }
      // If characters do not match
      else {
        dp[i][j] = MAX(dp[i][j - 1], dp[i - 1][j]);
      }
    }
  }

  // Find the maximum value in the dp table
  int maxLen = 0;
  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= n; j++) {
      if (dp[i][j] > maxLen) {
        maxLen = dp[i][j];
      }
    }
  }

  int actualMaxLen = maxLen;

  // Trace back through the dp table to find the actual repeating subsequence
  char *subseq = malloc((maxLen + 1) * sizeof(char));
  int i = n, j = n;
  while (i > 0 && j > 0) {
    if (str[i - 1] == str[j - 1] && i != j) {
      subseq[--maxLen] = str[i - 1];
      i--;
      j--;
    } else if (dp[i - 1][j] > dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }

  // Free dynamically allocated memory
  for (int i = 0; i <= n; i++) {
    free(dp[i]);
  }
  free(dp);
  free(subseq);

  return actualMaxLen;
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

  while (num_rocks < 1098+83) { // loop for a single turn:
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

//      if (PLAYFIELD[(2759*2)+134] == 62) {
//        printf("num_rocks fallen: %d, max_height: %d\n", num_rocks, max_rock_height);
//        exit(0);
//      }
//      if ((PLAYFIELD[134] & 0b1111111) == 0b1111111) {
//        printf("num_rocks fallen: %d, max_height: %d\n", num_rocks, max_rock_height);
//        print_s(max_rock_height+5, falling_shape, falling_bot);
//        exit(1);
//      }

      falling_shape = SHAPES[num_rocks++ % NUM_SHAPES];
      falling_shape = shape_try_rshift(falling_shape, -1, SHAPE_START_OFF);
      falling_bot = add_new_piece(falling_shape, max_rock_height);
    } else {
      falling_bot--;
    }
  }


  printf("part 1: %d\n", max_rock_height);

//  // find maximum length string that repeats 4 times adjacently
//  int max_len = 0;
//  int num_repeats = 50;
//  for (int len = max_rock_height / num_repeats; len > 100; len--) {
//    for (int i = 0; i + len*num_repeats < max_rock_height; i++) {
//      for (int r = 0; r < num_repeats; r++) {
//        if (strncmp(PLAYFIELD + i + r * len, PLAYFIELD + i + (r + 1) * len, len) != 0) {
//          goto next_i;
//        }
//      }
//      printf("len: %d, i: %d\n", len, i);
//      exit(1);
//    next_i:
//      continue;
//    }
//  }
//
//  long long part2_fallen_rocks = 1000000000000LL;
//
//  printf("max_len: %d\n", max_len);
  // answer found through the following steps:
  // 1. find the repititon using the above code
  // 2. find the number of rocks that fall before the repetition starts
  // 3. that's PLAYFIELD[134], though it doesn't fill in until 2 more rocks fall
  // 4. so 82 rocks fallen makes the base before the repitition starts
  // 5. base 137 height, 82 rocks
  // 6. (1_000_000_000_000 - 82) % 1740
  // 7. 1740 is how many rocks til the pattern repeats, after height 137
  // 8. formula is like:
  //  height = (2759*n)+137
  //  rocks = (1740*n)+82
  // anyway i got the answer but not going to write the code

  // In [19]: 1585632182037+1878
  // Out[19]: 1585632183915
}
