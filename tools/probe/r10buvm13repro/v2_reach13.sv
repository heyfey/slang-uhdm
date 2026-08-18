// r10buvm13 arm v2 — THE REACH FENCE for a FORMAL'S DEFAULT VALUE.
// Axes this arm owns and v1 does not: a MODULE function/task (default naming an
// earlier formal, a module PARAMETER, a module NET and a module VARIABLE), a
// $unit-scope function (unitSubNoBind9's population), an INTERFACE function,
// a class declared INSIDE a module, and a formal whose default names a
// PRECEDING formal from a POSITION OTHER than a bare operand (a call argument,
// a concatenation, an index).
function automatic int u13_earlier(int a, int b = a);   return a + b; endfunction
function automatic int u13_const(int b = 3);            return b; endfunction

interface if13;
  parameter int IP13 = 9;
  typedef enum int {IE13_A = 1, IE13_B = 2} ie13_t;
  function automatic int if_enumi(int v = IE13_B);      return v; endfunction
  function automatic int if_earlier(int a, int b = a);  return a + b; endfunction
  function automatic int if_param(int v = IP13);        return v; endfunction
endinterface
// The SECOND interface is INSTANTIATED (if13 is not): an UNinstantiated
// component may simply never reach Surelog's lateBinding, so a fence read off
// if13 alone would be an artefact of elaboration, not a rule.
interface if13b;
  parameter int IPB13 = 9;
  logic [7:0] ifnet13;
  function automatic int ifb_earlier(int a, int b = a); return a + b; endfunction
  function automatic int ifb_net(int v = ifnet13);      return v; endfunction
endinterface

// An UNINSTANTIATED MODULE, to separate "interface" from "never elaborated"
// as the reason if13's cells stay bare.
module m13_unused;
  parameter int UP13 = 4;
  logic [7:0] unet13;
  function automatic int uf_earlier(int a, int b = a);   return a + b; endfunction
  function automatic int uf_net(int v = unet13);         return v; endfunction
endmodule

// An uninstantiated module WITH PORTS: slang auto-tops a portless module, so
// m13_unused above is elaborated after all.  This one cannot be, which is the
// real "definition view only" cell -- the same shape the uninstantiated
// INTERFACE if13 has.
module m13_unused2(input logic p13x);
  logic [7:0] u2net13;
  function automatic int uf2_earlier(int a, int b = a);  return a + b; endfunction
  function automatic int uf2_net(int v = u2net13);       return v; endfunction
endmodule

module m13;
  parameter int MP13 = 2;
  localparam int ML13 = 6;
  typedef enum int {M13_A = 1, M13_B = 2} me13_t;
  wire   [7:0] mnet13;
  logic  [7:0] mvar13;

  function automatic int mf_earlier(int a, int b = a);        return a + b; endfunction
  function automatic int mf_param  (int v = MP13);            return v; endfunction
  function automatic int mf_local  (int v = ML13);            return v; endfunction
  function automatic int mf_net    (int v = mnet13);          return v; endfunction
  function automatic int mf_var    (int v = mvar13);          return v; endfunction
  function automatic int mf_enum   (me13_t e = M13_B);        return int'(e); endfunction
  function automatic int mf_arg    (int a, int b = mf_param(a)); return a + b; endfunction
  function automatic int mf_concat (int a, int b = {a, a});   return a + b; endfunction
  function automatic int mf_idx    (int a, int b = mnet13[a]); return a + b; endfunction
  task automatic mt_earlier(input int a, input int b = a);    endtask

  class cm13;
    function int cm_earlier(int a, int b = a);                return a + b; endfunction
    function int cm_enum   (me13_t e = M13_B);                return int'(e); endfunction
    extern function int cx_earlier(int a, int b = a);
  endclass
  function int cm13::cx_earlier(int a, int b = a);            return a + b; endfunction

  if13b u_if13b();
  int z13;
  initial begin
    z13 = u_if13b.ifb_earlier(1);
    z13 = u_if13b.ifb_net();
    z13 = mf_earlier(1);
    z13 = mf_param();
    z13 = mf_local();
    z13 = mf_net();
    z13 = mf_var();
    z13 = mf_enum();
    z13 = mf_arg(1);
    z13 = mf_concat(1);
    z13 = mf_idx(1);
    mt_earlier(1);
    z13 = u13_earlier(1);
    z13 = u13_const();
  end
endmodule
