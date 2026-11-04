// § streamPartSelLazyName288 — a streaming part-select in a class static function, a class task and a module function result in a ternary
class sc;
  static function logic [7:0] cf(logic [7:0] v); return {<< {v[3:0], v[7:4]}}; endfunction
  task ct(input logic [7:0] v, output logic [7:0] r); r = v[0] ? {<< 2 {v[5:0], 2'b1}} : v; endtask
endclass
module top(input logic [7:0] i, output logic [7:0] o);
  function automatic logic [7:0] mf(logic [7:0] v); return i[1] ? {<< {v[1:0], v[7:2]}} : '0; endfunction
  always_comb o = mf(i) ^ sc::cf(i);
endmodule
