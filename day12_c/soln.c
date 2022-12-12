#include <stdio.h>
#include <stdbool.h>
#include <limits.h>
#include <string.h>

#if(1)
#define FILENAME "sample.txt"
#define HEIGHT 5
#define WIDTH 8
#else
#define FILENAME "input.txt"
#define HEIGHT 41
#define WIDTH 101
#endif


int reachable_nbors(char grid[HEIGHT][WIDTH], int pos[2],
                    int neighbors[4][2]) {
  char val_this_square = grid[pos[1]][pos[0]];

  int neighbor_count = 0;
  int dirs[4][2] = {{1, 0}, {-1, 0}, {0, -1}, {0, 1}};
  for (int i = 0; i < 4; i++) {
    int nx = dirs[i][0] + pos[0];
    int ny = dirs[i][1] + pos[1];
    if (nx < 0 || ny < 0 || ny >= HEIGHT || nx >= WIDTH)
      continue;

    // can reach neighbors that are 1 higher or lower
    int diff = grid[ny][nx] - val_this_square;
    if (diff <= 1) {
      neighbors[neighbor_count][0] = nx;
      neighbors[neighbor_count][1] = ny;
      neighbor_count++;
    }
  }
  return neighbor_count; 
}

int main() {
  FILE* file = fopen(FILENAME, "r");
  char grid[HEIGHT][WIDTH];
  int min_steps[HEIGHT][WIDTH] = {{INT_MAX}};

  int starting_pos[2];
  int ending_pos[2];

  int parse_height = 0;
  int parse_width = 0;
  while (true) {
    char c = getc(file);
    if (c == EOF) break;
    if (c == '\n') {
      parse_height++;
      parse_width = 0;
      continue;
    }
    if (c == 'S') {
      starting_pos[0] = parse_width;
      starting_pos[1] = parse_height;
      c = 'a';
    } else if (c == 'E') {
      ending_pos[0] = parse_width;
      ending_pos[1] = parse_height;
      c = 'z';
    }
    grid[parse_height][parse_width++] = c;
    printf("got: %c\n", c);
  }

  while (memcmp(starting_pos, ending_pos, 2) != 0) {
  }
  int nbors[4][2];
  int p[2] = {2, 0};
  for (int i = 0; i < reachable_nbors(grid, p, nbors); i++) {
    printf("neighbor: %d %d\n", nbors[i][0], nbors[i][1]);
  }

}
