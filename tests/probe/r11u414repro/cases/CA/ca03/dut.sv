// § classArrElemVar414
package p; class C; int x; endclass endpackage
module top();
  p::C arr[4];
  initial begin arr[1] = new; arr[1].x = 3; end
endmodule
