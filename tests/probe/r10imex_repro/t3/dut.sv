// t3 — `const int` (and const logic) inside an interface AND inside a module.
interface I;
const int x = 1;
const logic [3:0] y = 4'h5;
int z = 2;
endinterface

module top();
  const int mx = 3;
  int mz = 4;
  I inst();
endmodule
