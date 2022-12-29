#include <ctype.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <sys/queue.h>

#define TIME_REMAINING 24

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

typedef struct QItem {
  Playstate playstate;
  SLIST_ENTRY(QItem) entries;
} QItem;

typedef SLIST_HEAD(slisthead, QItem) Q;

Q q_init() {
  Q q;
  SLIST_INIT(&q);
  return q;
}

bool q_is_empty(Q *q) { return SLIST_EMPTY(q); }

Playstate q_pop(Q *q) {
  QItem *entry = SLIST_FIRST(q);
  Playstate playstate = entry->playstate;
  SLIST_REMOVE_HEAD(q, entries);
  free(entry);
  return playstate;
}

void q_push(Q *q, Playstate playstate) {
  QItem *entry = malloc(sizeof(QItem));
  entry->playstate = playstate;
  SLIST_INSERT_HEAD(q, entry, entries);
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

Materials collection_phase(const Playstate playstate) {
  RobotArmy army = playstate.robot_army;
  Materials materials = {.ore = army.num_ore_robots,
                         .clay = army.num_clay_robots,
                         .obs = army.num_obs_robots,
                         .geode = army.num_geode_robots};
  return materials;
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
    //return options;
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
  uint32_t max_num_geodes = 0;
  Q q = q_init();
  q_push(&q, initial_state);
  while (!q_is_empty(&q)) {
    Playstate this_state = q_pop(&q);
    if (this_state.time_remaining == 0) {
      max_num_geodes = MAX(max_num_geodes, this_state.mats.geode);
      continue;
    }
    Materials collected_mats = collection_phase(this_state);
    BuildOptions options = building_phase(blueprint, this_state);
    for (uint8_t i = 0; i < options.len; i++) {
      Playstate option = options.buildable_robots[i];
      option.mats.ore += collected_mats.ore;
      option.mats.clay += collected_mats.clay;
      option.mats.obs += collected_mats.obs;
      option.mats.geode += collected_mats.geode;
      option.time_remaining--;
      q_push(&q, option);
    }
  }
  return max_num_geodes * blueprint.id;
}

void *max_quality_thread(void *blueprint) {
  Blueprint *bp = (Blueprint *)blueprint;
  uint32_t max_quality = max_quality_level(*bp, init_playstate());
  free(bp);
  return (void *)(intptr_t)max_quality;
}

int main() {
  FILE *f = fopen("input.txt", "r");
  if (f == NULL) {
    printf("Error opening file");
    return 1;
  }
  uint32_t total_sum = 0;

  pthread_t threads[100];
  uint8_t num_threads = 0;

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
  }
  for (uint8_t i = 0; i < num_threads; i++) {
    void *result;
    pthread_join(threads[i], &result);
    printf("finished one robot\n");
    total_sum += (uint32_t)(intptr_t)result;
  }

  printf("part 1: %d\n", total_sum);
}
