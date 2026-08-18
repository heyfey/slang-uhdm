// v99 b4 - deeper shapes: nested parens, nested inside, casts, function-call
// bounds, concatenation bounds, generate/genvar, package scope, 3 instances.
package pk99b4;
  localparam int PLB4 = 2;
  localparam int PHB4 = 12;
  function automatic int fbb4(int ab4); return ab4 + 1; endfunction
endpackage

module mub4 #(parameter int KB4 = 1) (input logic ckb4);
  import pk99b4::*;
  int hb41, hb42, hb43, hb44, hb45, hb46, hb47, hb48, hb49;
  logic [3:0] pb41;
  int jb4 [$];
  int cb41, cb42, cb43, cb44, cb45, cb46, cb47, cb48, cb49;

  always @(*) begin
    // nested parentheses around the whole set member's first bound
    if (hb41 inside {[((PLB4)):PHB4]})        cb41 = 1;
    // parenthesised LHS with a ranged set
    if ((hb42 + 1) inside {[PLB4:PHB4], 20})  cb42 = 2;
    // function-call first bound
    if (hb43 inside {[fbb4(2):PHB4]})         cb43 = 3;
    // cast first bound
    if (hb44 inside {[int'(PLB4):PHB4]})      cb44 = 4;
    // concatenation first bound
    if (pb41 inside {[{2'b01,2'b10}:4'hF]})   cb45 = 5;
    // nested inside as the LHS of another inside
    if ((hb45 inside {[1:4]}) inside {[0:1]}) cb46 = 6;
    // ranged set beside a plain set in one expression
    if ((hb46 inside {[1:4]}) && (hb47 inside {8, 9})) cb47 = 7;
    // negated ranged inside
    if (!(hb48 inside {[3:6], 11}))           cb48 = 8;
    // ranged inside on a queue element
    if (jb4[0] inside {[2:5]})                cb49 = 9;
    // ranged inside whose first member is a queue element
    if (hb49 inside {jb4[1], [2:5]})          cb41 = 10;
  end

  generate
    if (KB4 inside {1,2}) begin : gnb4
      initial cb42 = 99;
    end
  endgenerate

  genvar gvb4;
  generate
    for (gvb4 = 0; gvb4 < 2; gvb4++) begin : glb4
      always @(*) if (hb41 inside {[gvb4:PHB4]}) cb43 = gvb4;
    end
  endgenerate
endmodule

module topb4;
  logic ckt4;
  mub4 #(1) x1b4 (.ckb4(ckt4));
  mub4 #(2) x2b4 (.ckb4(ckt4));
  mub4 #(3) x3b4 (.ckb4(ckt4));
endmodule
