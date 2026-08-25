// r10uvm147 VERIFIER grid H — the HOME axis the briefing names and the
// implementer's grids do not reach: a $unit-scope class, a class declared
// INSIDE a module, a PROGRAM block, a function inside an INTERFACE, a module
// TASK and a module function with a `ref` formal, and 1-3 instances.
class u147h;
  logic [63:0] value[];
  logic [63:0] fix[4];
endclass

class u147huser;                       // $unit-scope class
  function void g(u147h fa, int idx, int i);
    logic [7:0] o;
    o = fa.value[idx][8*i +: 8];       // h01 $unit class, formal receiver
    o = fa.fix[idx][8*i +: 8];         // h02 $unit class, fixed unpacked
  endfunction
endclass

interface if147h;
  logic [63:0] arr[4];
  function automatic logic [7:0] gi(u147h fa, int idx, int i);
    return fa.value[idx][8*i +: 8];    // h03 function inside an INTERFACE
  endfunction
  task automatic ti(u147h fa, int idx, int i);
    logic [7:0] o;
    o = fa.fix[idx][8*i +: 8];         // h04 task inside an INTERFACE
  endtask
endinterface

program p147h;
  u147h ph;
  int idx, i;
  logic [7:0] o;
  initial o = ph.value[idx][8*i +: 8]; // h05 PROGRAM initial, module-var-like
  function automatic void pf(u147h fa, int idx2, int i2);
    logic [7:0] o2;
    o2 = fa.value[idx2][8*i2 +: 8];    // h06 function in a PROGRAM
  endfunction
endprogram

module m147h;
  class inmod147;                      // a class declared INSIDE a module
    function void g(u147h fa, int idx, int i);
      logic [7:0] o;
      o = fa.value[idx][8*i +: 8];     // h07 module-scope class
    endfunction
  endclass

  u147h h1, h2, h3;
  int idx, i;
  logic [7:0] o;

  task automatic mt(u147h fa, int idx2, int i2);
    o = fa.value[idx2][8*i2 +: 8];     // h08 MODULE TASK, formal receiver
  endtask

  function automatic void mf(ref u147h fr, int idx2, int i2);
    o = fr.value[idx2][8*i2 +: 8];     // h09 MODULE function, `ref` formal
  endfunction

  initial begin
    o = h1.value[idx][8*i +: 8];       // h10 instance 1
    o = h2.value[idx][8*i +: 8];       // h11 instance 2
    o = h3.value[idx][8*i +: 8];       // h12 instance 3
  end
endmodule
