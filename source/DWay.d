// TODO: Move loop itself into `coreloop`, keeping switch logic in individual loops.

module DWay;

// nice-curses imports
public import nice.curses;

// Phobos imports
public import core.thread : Thread;
public import core.time : msecs;
public import std.conv : to;
public import std.random : dice;
public import std.stdio : File, stderr, writeln;

class Field {
    
    private uint height;
    private uint width;
    private char[][] map;
    private char[][] startMap;
    
    Curses curses;
    Window stdscr;

    bool[string] bools;
    int y, x;

    this() {
        Curses.Config cfg = {
            /*useColors*/    true,
            /*useStdColors*/ true,
            /*disableEcho*/  true,
            /*mode*/         Curses.Mode.cbreak,
            /*cursLevel*/    1,
            /*initKeypad*/   true,
            /*nl*/           false,
            /*nodelay*/      true
        };
        this.curses = new Curses(cfg);
        scope(exit) destroy(curses);

        this.stdscr = curses.stdscr;
        this.stdscr.timeout(0);

        this.height = stdscr.height() - 1;
        this.width  = stdscr.width() - 1;
        this.map = new char[][](this.height, this.width);
        foreach (i; 0 .. this.height) {
            foreach (j; 0 .. this.width) {
                this.map[i][j] = ' ';
            }
        }

        this.coreloop();
    }

    // Manage coreloop things
    void coreloop() {
        char ch;
        
        bools = ["paused": false, "started": false, "run": true];
        y = x = 0;
        
        while (bools["run"]) {
            Thread.sleep(msecs(200));
            
            try {
                ch = to!char(stdscr.getch());
            } catch (Exception e) { ch = ';'; }
            
            if (ch == 'q') {
                bools["run"] = false;
            } else if (!bools["started"]) {
                stdscr.addstr(this.height, 0, "In startloop.");

                this.startloop(ch);
            } else if (bools["paused"]) {
                stdscr.addstr(this.height, 0, "In pauseloop.");
                
                this.pauseloop(ch);
            } else {
                stdscr.addstr(this.height, 0, "In mainloop.");
                
                this.mainloop(ch);
            }
        }
    }

    // Setup initial state
    void startloop(ref char ch) {
        stdscr.move(y, x);
        switch (ch) {
                
            // Easter egg
            case 'c':
                this.goodbyeConway();
                break;

            // general

            case 'g':
                this.map[y][x] = this.map[y][x] == ' ' ? '*' : ' ';
                this.printWorld();
                break;

            case ' ':
                this.startMap = this.map.dup();
                bools["started"] = true;
                break;

            // navigation

            case 'k':
                //up
                y -= y > 0 ? 1 : 0;
                break;

            case 'j':
                //down
                y += y < this.height ? 1 : 0;
                break;

            case 'h':
                //left
                x -= x > 0 ? 1 : 0;
                break;

            case 'l':
                //right;
                x += x < this.width ? 1 : 0;
                break;

            case 'r':
                this.randGen();
                break;

            default: break;
        }
    }

    // Handle interactive events while iterating generations
    void mainloop(ref char ch) {
        switch (ch) {
            case ' ':
                bools["paused"] = true;
                break;

            default: break;
        }

        this.iterGen();
    }

    // Handle pause state
    void pauseloop(ref char ch) {
        switch (ch) {
            case 'd':
                this.dumpMap();
                break;

            case 'r':
                this.map = this.startMap.dup();
                this.printWorld();
                break;

            case ' ':
                bools["paused"] = false;
                break;
                
            default: break;
        }
    }

    // Print the current map state to the screen.
    void printWorld() {
        stdscr.clear();
        foreach (i; 0 .. this.height) {
            foreach (j; 0 .. this.width) {
                stdscr.insert(i, j, this.map[i][j]);
            }
        }
        curses.update();
    }

    // Iterate the generation
    void iterGen() {
        char[][] tempMap = new char[][](this.height, this.width);
        foreach (i; 0 .. this.height) {
            foreach (j; 0 .. this.width) {
                int neighbors = 0;

                if (i < this.height-1) {
                    
                    neighbors += this.map[i+1][j] == '*' ? 1 : 0;

                    if (j < this.width-1)
                        neighbors += this.map[i+1][j+1] == '*' ? 1 : 0;

                    if (j > 0)
                        neighbors += this.map[i+1][j-1] == '*' ? 1 : 0;
                }

                if (j < this.width - 1)
                    neighbors += this.map[i][j+1] == '*' ? 1 : 0;

                if (j > 0)
                    neighbors += this.map[i][j-1] == '*' ? 1 : 0;

                if (i > 0) {
                    neighbors += this.map[i-1][j] == '*' ? 1 : 0;

                    if (j > 0)
                        neighbors += this.map[i-1][j-1] == '*' ? 1 : 0;

                    if (j < this.width-1)
                        neighbors += this.map[i-1][j+1] == '*' ? 1 : 0;
                }
            
                if (this.map[i][j] == ' ')
                    tempMap[i][j] = neighbors == 3 ? '*' : ' ';
                else if (this.map[i][j] == '*')
                    tempMap[i][j] = neighbors < 2 || neighbors > 3 ? ' ' : '*';
            }
        }

        this.map = tempMap.dup();
        this.printWorld();
        destroy(tempMap);
    }

    void randGen() {
        foreach (i; 0 .. this.height) {
            foreach (j; 0 .. this.width) {
                map[i][j] = dice(1, 8) == 0 ? '*' : ' ';
            }
        }
        this.printWorld();
    }

    void dumpMap() {
        auto fp = File("dway.dmp", "w");
        foreach (i; 0 .. this.height) {
            foreach (j; 0 .. this.width) {
                fp.write(map[i][j]);
            }
            fp.write("\n");
        }
    }

    void goodbyeConway() {
        //TODO
    }
}
