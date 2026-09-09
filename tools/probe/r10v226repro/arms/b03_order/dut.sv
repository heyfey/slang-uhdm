// v226 b03 — process ORDER interleaved with nets, params, cont_assigns,
// typedefs, tasks and modports in an uninstantiated interface.
interface bo_if;
  logic w0;
  initial w0 = 0;                 // P1
  wire   w1;
  parameter int PP = 3;
  always_comb begin end           // P2 (empty body)
  assign w1 = w0;
  typedef logic [1:0] t_t;
  t_t tv;
  final tv = 2'b01;               // P3
  task automatic tk(); tv = 0; endtask
  modport mp (input w0, output tv);
  always @(w0) tv = {2{w0}};      // P4
endinterface
