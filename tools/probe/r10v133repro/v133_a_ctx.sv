// r10v133 arm A - $bits(<call>) in NON-CLASS homes and CONSTANT contexts.
// MEASUREMENT ONLY.  golden (Surelog) is ALWAYS LHS.
package pv133a;
  function automatic int pfa133(); return 4; endfunction
  function automatic int pfb133(input int k); return k + 1; endfunction
endpackage

module vsub133 #(parameter int WS = 8) (input logic [WS-1:0] ia, output logic [7:0] oa);
  assign oa = ia[7:0];
endmodule

module vm133a;
  import pv133a::*;
  logic [7:0] nw;
  logic [7:0] ny;
  int         rr;
  int         dq133[$];
  int         aq133[string];
  int         da133[];
  string      sv133;

  function automatic int mfa133(); return 3; endfunction

  // C01 param_assign Rhs, a package free function
  parameter  int PA133 = $bits(pfa133());
  // C02 localparam Rhs, a module function
  localparam int LA133 = $bits(mfa133());
  // C03 localparam Rhs, a call with an argument
  localparam int LB133 = $bits(pfb133(2));
  // C04 PACKED RANGE BOUND over a call
  logic [$bits(mfa133())-1:0] rngv133;
  // C05 UNPACKED range bound over a call
  logic ua133 [$bits(mfa133())];
  // C06 net-decl-assign rhs
  wire [7:0] ndav133 = 8'($bits(dq133.size()));
  // C07 continuous assign
  assign nw = 8'($bits(mfa133()));
  // C08 High_conn param override
  vsub133 #(.WS($bits(pfa133()))) uv133 (.ia(nw), .oa(ny));

  initial begin
    // C09 case item
    case (rr)
      $bits(mfa133()) : rr = 1;
      $bits(dq133.size()) : rr = 2;
      default : rr = 3;
    endcase
    // C10 for-loop bound
    for (int i = 0; i < $bits(mfa133()); i++) rr = rr + i;
    // C11 replication count
    nw = {$bits(mfa133()){1'b1}};
    // C12 associative array size
    rr = $bits(aq133.size());
    // C13 associative array num
    rr = $bits(aq133.num());
    // C14 dynamic array size
    rr = $bits(da133.size());
    // C15 string len
    rr = $bits(sv133.len());
    // C16 nested call
    rr = $bits(pfb133(mfa133()));
    // C17 scoped package call
    rr = $bits(pv133a::pfa133());
  end

  // C18 inside a generate-for
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk133
      int gr;
      initial gr = $bits(mfa133());
    end
  endgenerate

  // C19 task body
  task automatic tk133();
    rr = $bits(mfa133());
  endtask
endmodule
