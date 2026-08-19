// r10uvm101 discovery grid: event-trigger VpiName path shapes.
package p101;
  event pev;
  class leaf101;
    event done;
  endclass
  class holder101;
    leaf101 one;
    leaf101 map[int];
    event direct;
    task fire();
      ->direct;
      ->this.direct;
      ->one.done;
      ->map[1].done;
    endtask
  endclass
endpackage

interface if101;
  event iev;
endinterface

module child101;
  event cev;
endmodule

module top101;
  import p101::*;
  event ev;
  holder101 h;
  if101 intf();
  child101 child();
  initial begin
    h = new;
    h.one = new;
    h.map[1] = new;
    ->ev;
    ->h.direct;
    ->h.one.done;
    ->h.map[1].done;
    ->intf.iev;
    ->child.cev;
    ->> #1 ev;
    h.fire();
  end
endmodule
