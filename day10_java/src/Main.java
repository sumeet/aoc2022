import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Stream;

import static java.lang.Math.abs;



public class Main {
    private static final int SCREEN_WIDTH = 40;
    private static final int SCREEN_HEIGHT = 6;

    public static void main(String[] args) throws IOException {
        int[] interestingCycleCount = new int[]{20, 60, 100, 140, 180, 220};
        int x = 1;
        int cycleCount = 0;
        int part1 = 0;

        // part2 vars:
        boolean[] screen = new boolean[SCREEN_WIDTH * SCREEN_HEIGHT];

        Stream<String> stream = Files.lines(Path.of("input.txt"));
        for (String line : (Iterable<String>) stream::iterator) {
            int nextX = x;
            int cycleCountNextTime = cycleCount;

            String[] parts = line.split(" ");
            String instruction = parts[0];
            if (instruction.equals("addx")) {
                int inc = Integer.parseInt(parts[1]);
                nextX += inc;
                cycleCountNextTime += 2;
            } else if (instruction.equals("noop")) {
                cycleCountNextTime++;
            }

            for (int interestingCount : interestingCycleCount) {
                if (interestingCount > cycleCount && interestingCount <= cycleCountNextTime) {
                    // then the instruction has not finished yet so use the old X
                    part1 += x * interestingCount;
                }
            }

            for (int crtDrawPos = cycleCount; crtDrawPos < cycleCountNextTime; crtDrawPos++) {
                if (abs(crtDrawPos % SCREEN_WIDTH - x) <= 1) {
                    screen[crtDrawPos] = true;
                }
            }

            x = nextX;
            cycleCount = cycleCountNextTime;
        }

        System.out.println("part 1: " + part1);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < screen.length; i++) {
            sb.append(screen[i] ? "#" : " ");
            if (i % SCREEN_WIDTH == SCREEN_WIDTH - 1) {
                sb.append("\n");
            }
        }
        System.out.println("part 2:\n" + sb.toString());
    }
}