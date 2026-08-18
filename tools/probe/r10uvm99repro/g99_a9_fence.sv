// r10uvm99 arm a9 — THE FENCE.  Every `inside` set here has NO `[a:b]` member,
// so Surelog parses `{...}` as a Concatenation and flattens EVERY member.
// The law must move NOTHING in this file, in either view.
package nu99_pkg;
  localparam int QA = 3;
endpackage
module xi99 (input logic [3:0] din99, output logic ok99);
  import nu99_pkg::*;
  int bagx99 [$];
  int p1, p2;
  assign ok99 = din99 inside {4'd1, 4'd2, 4'd5};
  function automatic bit c1(int vv); return vv inside {1}; endfunction
  function automatic bit c2(int vv); return vv inside {1, 2, 3}; endfunction
  function automatic bit c3(int vv); return vv inside {QA, p1, p2}; endfunction
  function automatic bit c4(int vv); return vv inside {p1 + p2, 8}; endfunction
  function automatic bit c5(int vv); return vv inside {bagx99}; endfunction
  function automatic bit c6(int vv); return vv inside {bagx99[0], bagx99[1]}; endfunction
  function automatic bit c7(string sv); return sv inside {"qq", "rr", "ss"}; endfunction
  task automatic t1(int vv); if (vv inside {6, 7}) p1 = vv; endtask
  always_comb p2 = (din99 inside {4'd9}) ? 1 : 0;
endmodule
