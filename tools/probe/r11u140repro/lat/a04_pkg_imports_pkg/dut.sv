// § impLhsCloneArrayTsOwnCopy140
package pa;
  parameter int A[2] = '{4, 5};
endpackage
package pb;
  import pa::*;
  parameter int B = 1;
endpackage
module dut(input logic sel, output int o);
  import pb::*;
  assign o = B + pa::A[sel];
endmodule
