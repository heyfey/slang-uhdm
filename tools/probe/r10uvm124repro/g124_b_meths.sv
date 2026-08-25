// r10uvm124 arm B — the METHOD axis over one indexed receiver: built-in queue
// and associative methods, a user-defined method, a void function and a task,
// with and without arguments, all in STATEMENT position.
package Meths124;
  class Cell;
    int  Slots[$];
    int  Tags[string];
    function void Poke(int V); endfunction
    function int  Peek(); return 3; endfunction
    task Wait7(); endtask
  endclass
  class Rack;
    Cell Row[$];
    Cell Map[string];
    task automatic Exercise(int Ix, string Sx);
      Row[Ix].Slots.push_back(11);
      Row[Ix].Slots.push_front(12);
      Row[Ix].Slots.delete();
      Row[Ix].Slots.delete(0);
      Row[Ix].Tags.delete(Sx);
      Row[Ix].Poke(13);
      Row[Ix].Wait7();
      Map[Sx].Slots.push_back(14);
      Map[Sx].Poke(15);
      Row[Ix].Slots.pop_back();
    endtask
  endclass
endpackage
