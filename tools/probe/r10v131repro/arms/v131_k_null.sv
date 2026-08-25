// v131 arm K — item lists that slang and Surelog might count differently:
// null statements, localparams, typedefs, empty begins.
module Knull;
  int kk;
  initial begin
    fork ; join_none                      // ONE null statement, unnamed
    fork ; join_any
    fork ;; join_none                     // TWO null statements
    fork : kA ; join_none : kA
    fork : kB ;; join_any : kB
    fork localparam int LPA = 3; join_none
    fork : kC localparam int LPB = 4; join_any : kC
    fork typedef int t_ka; join_none
    fork : kD typedef int t_kb; join_any : kD
    fork begin end join_none
    fork : kE begin end join_any : kE
    fork begin end begin end join_none
    fork : kF begin ; end join_none : kF
    kk = 1;
  end
endmodule
