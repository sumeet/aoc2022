#include <ctype.h>
#include <memory.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define TIME_REMAINING 32

typedef struct Blueprint {
  uint8_t id;
  uint8_t ore_robot_ore_cost;
  uint8_t clay_robot_ore_cost;
  uint8_t obs_robot_ore_cost;
  uint8_t obs_robot_clay_cost;
  uint8_t geode_robot_ore_cost;
  uint8_t geode_robot_obs_cost;
} Blueprint;

typedef struct RobotArmy {
  uint32_t num_ore_robots;
  uint32_t num_clay_robots;
  uint32_t num_obs_robots;
  uint32_t num_geode_robots;
} RobotArmy;

typedef struct Materials {
  uint32_t ore;
  uint32_t clay;
  uint32_t obs;
  uint32_t geode;
} Materials;

typedef struct Playstate {
  uint8_t time_remaining;
  Materials mats;
  RobotArmy robot_army;
} Playstate;

Playstate init_playstate() {
  Playstate playstate = {0};
  playstate.time_remaining = TIME_REMAINING;
  playstate.robot_army.num_ore_robots = 1;
  return playstate;
};

#define MAX_Q_SIZE 900000000 // 100k

typedef struct Q {
  Playstate items[MAX_Q_SIZE];
  uint32_t front;
  uint32_t rear;
} Q;

void print_playstate(Playstate ps) {
  printf("Playstate: time_remaining: %d", ps.time_remaining);
}

void q_push(Q *q, Playstate playstate) {
  if (q->rear == MAX_Q_SIZE - 1) {
    printf("Queue is Full!!\n");
    printf("tried to enqueue playstate:");
    print_playstate(playstate);
    exit(1);
  } else {
    if (q->front == -1)
      q->front = 0;
    q->rear++;
    q->items[q->rear] = playstate;
  }
}

Q *q_init(Playstate initial_playstate) {
  Q *q = malloc(sizeof(Q));
  q->front = -1;
  q->rear = -1;
  q_push(q, initial_playstate);
  return q;
}

bool q_is_empty(Q *q) { return q->rear == -1; }

Playstate q_pop(Q *q) {
  Playstate item;
  if (q_is_empty(q)) {
    printf("Queue is empty");
    exit(1);
  } else {
    item = q->items[q->front];
    q->front++;
    if (q->front > q->rear) {
      q->front = q->rear = -1;
    }
  }
  return item;
}

int read_next_int(FILE *f) {
  char c;
  while (!isdigit(c = getc(f)))
    if (c == EOF)
      return -1;
  ungetc(c, f);
  int i;
  fscanf(f, "%d", &i);
  return i;
}

typedef struct BuildOptions {
  Playstate buildable_robots[5];
  uint8_t len;
} BuildOptions;

BuildOptions building_phase(const Blueprint blueprint,
                            const Playstate playstate) {
  BuildOptions options = {0};
  Materials mats = playstate.mats;

  if (mats.obs >= blueprint.geode_robot_obs_cost &&
      mats.ore >= blueprint.geode_robot_ore_cost) {
    Playstate next_state = playstate;
    next_state.mats.obs -= blueprint.geode_robot_obs_cost;
    next_state.mats.ore -= blueprint.geode_robot_ore_cost;
    next_state.robot_army.num_geode_robots++;
    options.buildable_robots[options.len++] = next_state;
    // if you can build a geode robot, just bail out. this is correct
    return options;
  }
  if (mats.clay >= blueprint.obs_robot_clay_cost &&
      mats.ore >= blueprint.obs_robot_ore_cost) {
    Playstate next_state = playstate;
    next_state.mats.clay -= blueprint.obs_robot_clay_cost;
    next_state.mats.ore -= blueprint.obs_robot_ore_cost;
    next_state.robot_army.num_obs_robots++;
    options.buildable_robots[options.len++] = next_state;
    // not sure if this return is correct
    // return options;
  }
  if (mats.ore >= blueprint.clay_robot_ore_cost) {
    Playstate next_state = playstate;
    next_state.mats.ore -= blueprint.clay_robot_ore_cost;
    next_state.robot_army.num_clay_robots++;
    options.buildable_robots[options.len++] = next_state;
  }
  if (mats.ore >= blueprint.ore_robot_ore_cost) {
    Playstate next_state = playstate;
    next_state.mats.ore -= blueprint.ore_robot_ore_cost;
    next_state.robot_army.num_ore_robots++;
    options.buildable_robots[options.len++] = next_state;
    // not sure if this return is correct
    //    return options;
  }
  // didn't spend anything this turn
  options.buildable_robots[options.len++] = playstate;
  return options;
}

uint32_t max_quality_level(const Blueprint blueprint,
                           const Playstate initial_state) {
  uint32_t max_num_geodess[TIME_REMAINING] = {0};
  memset(max_num_geodess, 0, sizeof(max_num_geodess));
  Q *q = q_init(initial_state);
  while (!q_is_empty(q)) {
    Playstate this_state = q_pop(q);
    //        if (this_state.mats.geode <
    //        max_num_geodess[this_state.time_remaining]) {
    //          continue;
    //        }

    RobotArmy current_army = this_state.robot_army;
    BuildOptions options = building_phase(blueprint, this_state);
    for (uint8_t i = 0; i < options.len; i++) {
      Playstate option = options.buildable_robots[i];
      option.mats.ore += current_army.num_ore_robots;
      option.mats.clay += current_army.num_clay_robots;
      option.mats.obs += current_army.num_obs_robots;
      option.mats.geode += current_army.num_geode_robots;
      option.time_remaining--;
      if (option.mats.geode + option.robot_army.num_geode_robots >=
          max_num_geodess[option.time_remaining]) {
        max_num_geodess[option.time_remaining] = option.mats.geode;
        if (option.time_remaining > 0)
          q_push(q, option);
      }
    }
  }
  return max_num_geodess[0];
}

void *max_quality_thread(void *blueprint) {
  Blueprint *bp = (Blueprint *)blueprint;
  uint32_t max_quality = max_quality_level(*bp, init_playstate());
  free(bp);
  return (void *)(intptr_t)max_quality;
}

int main() {
  FILE *f = fopen("sample.txt", "r");
  if (f == NULL) {
    printf("Error opening file");
    return 1;
  }

  pthread_t threads[100];
  uint8_t num_threads = 0;
  uint32_t total_product = 1;

  int blueprint_id;
  while ((blueprint_id = read_next_int(f)) != -1) {
    Blueprint *blueprint = malloc(sizeof(Blueprint));
    blueprint->id = blueprint_id;
    blueprint->ore_robot_ore_cost = read_next_int(f);
    blueprint->clay_robot_ore_cost = read_next_int(f);
    blueprint->obs_robot_ore_cost = read_next_int(f);
    blueprint->obs_robot_clay_cost = read_next_int(f);
    blueprint->geode_robot_ore_cost = read_next_int(f);
    blueprint->geode_robot_obs_cost = read_next_int(f);
    pthread_create(&threads[num_threads++], NULL, max_quality_thread,
                   blueprint);
    // only 3 blueprints considered for part 1
    if (blueprint->id == 3)
      break;
  }
  for (uint8_t i = 0; i < num_threads; i++) {
    uint32_t result;
    pthread_join(threads[i], (void *)&result);
    total_product *= result;
    printf("finished one robot (#%d): %d\n", i, result);
  }
  printf("part 2: %d\n", total_product);
}
