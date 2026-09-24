// § impLhsCloneFile124
package p; parameter int A = 3; endpackage
interface bi; import p::*; logic [A-1:0] d; endinterface
module top(output logic [2:0] o); bi b(); assign b.d = '1; assign o = b.d; endmodule
