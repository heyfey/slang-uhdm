// r10uvm147 arm C — the receiver kinds the gate must DECIDE about: a
// PARAMETER / LOCALPARAM struct base carrying a real element step, a CLOCKING
// VAR, an interface MODPORT port, a hierarchical reference, an enum-typed
// member, and a chain of TWO member accesses.  These are the kinds arm B could
// not reach; each one is measured against golden before the gate is widened.
package q147c;
  typedef struct { logic [63:0] arr[4]; logic [63:0] pk; } sc147_t;
  localparam sc147_t PC = '{arr:'{64'h1,64'h2,64'h3,64'h4}, pk:64'h9};

  typedef struct { logic [63:0] arr[4]; } inner_t;
  typedef struct { inner_t in; logic [63:0] pk; } outer_t;

  class deep147;
    inner_t din;
    logic [63:0] value[];
  endclass

  class holder147;
    deep147 dh;
  endclass

  function automatic void f147c(outer_t so, holder147 hh, int idx, int i);
    logic [7:0] o;
    o = PC.arr[idx][8*i +: 8];        // c01 LOCALPARAM struct base, one step
    o = PC.arr[2][8*i +: 8];          // c02 LOCALPARAM struct base, literal
    o = so.in.arr[idx][8*i +: 8];     // c03 TWO member accesses, formal base
    o = hh.dh.value[idx][8*i +: 8];   // c04 TWO member accesses through handles
    o = hh.dh.din.arr[idx][8*i +: 8]; // c05 THREE member accesses
  endfunction
endpackage

interface if147c;
  logic [63:0] arr[4];
  logic [63:0] pk;
  modport mp (input arr, input pk);
endinterface

module sub147c (if147c.mp p, input logic clk);
  import q147c::*;
  int idx, i;
  logic [7:0] o;
  initial o = p.arr[idx][8*i +: 8];   // c06 MODPORT port base
endmodule

module m147c;
  import q147c::*;
  logic clk = 0;
  if147c bus();
  sub147c u_s (.p(bus.mp), .clk(clk));
  int idx, i;
  logic [7:0] o;
  outer_t mo;
  initial begin
    o = bus.arr[idx][8*i +: 8];       // c07 interface INSTANCE base
    o = u_s.o;                        // (a plain hierarchical read)
    o = mo.in.arr[idx][8*i +: 8];     // c08 module var, TWO member accesses
    o = PC.arr[idx][8*i +: 8];        // c09 module-scope LOCALPARAM base
  end

  clocking cb @(posedge clk);
    input o;
  endclocking
endmodule
