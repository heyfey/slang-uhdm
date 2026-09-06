// r10v175 verifier arm S — SCOPES that are not a package class.
interface tine_link;
  logic clk;
endinterface

module ridge_top;
  class prong;
    string marks[$];
    int loads[$];
    function new(); endfunction
  endclass
  class frame;
    prong ribs[$];
    int caught[$];
    int total;
    string aim;
    function new(); endfunction
    function void probe(int seat);
      // s_modclass: a class declared INSIDE a module
      caught = ribs[seat].marks.find_index() with (item == aim);
      total  = ribs[seat].loads.sum() with (item);
    endfunction
  endclass
  frame f;
  int seat;
  int total;
  initial begin
    f = new();
    // s_modinit: reached through a handle from the module body
    total = f.ribs[seat].loads.sum() with (item);
  end
  for (genvar gi = 0; gi < 2; gi++) begin : bay
    // s_genvar: a GENVAR index inside a generate block
    always @(*) total = f.ribs[gi].loads.sum() with (item);
  end
endmodule

program ridge_prog;
  class knob;
    int units[$];
    function new(); endfunction
  endclass
  class bank;
    knob dials[$];
    int total;
    function new(); endfunction
    function void tally(int pin);
      // s_program: inside a program block
      total = dials[pin].units.sum() with (item);
    endfunction
  endclass
endprogram
