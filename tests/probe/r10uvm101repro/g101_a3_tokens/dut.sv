// r10uvm101 adversarial grid: special base tokens, escaping, macros, and
// nonblocking dotted targets.
`define FIRE101(X) -> X;
package q101;
  class base101;
    event inherited;
  endclass
  class derived101 extends base101;
    event own;
    task fire();
      ->this.own;
    endtask
  endclass
endpackage

module kid101;
  event done;
endmodule

module token101;
  import q101::*;
  derived101 h;
  derived101 \h.dot ;
  kid101 kid();
  initial begin
    h = new;
    \h.dot  = new;
    `FIRE101(h.own)
    -> \h.dot .own;
    -> $root.token101.kid.done;
    ->> h.own;
    ->> #1 h.own;
    h.fire();
  end
endmodule
