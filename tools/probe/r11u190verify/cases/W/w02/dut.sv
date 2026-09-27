// § tfArgAggSwitchSplit180 (r11u190: a package UNION typedef taken by a class task output formal and a package function formal after it)
package p;
  typedef union packed { logic [7:0] w; logic [7:0] v; } u_t;
  class c;
    task put(output u_t x); x = 8'h1; endtask
  endclass
  function automatic logic [7:0] get(input u_t y); return y.w; endfunction
  localparam u_t U = 8'h5A;
endpackage
module top import p::*; (output logic [7:0] o);
  assign o = get(U);
endmodule
