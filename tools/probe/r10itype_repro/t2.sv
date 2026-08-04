interface zsub #(
  parameter int PA = 1
);
endinterface

interface acont (
  zsub  s
);
  logic z;
endinterface

interface asub #(
  parameter int PB = 1
);
endinterface

interface zcont (
  asub  t
);
  logic y;
endinterface

module top();

zsub #(5) u_z();
acont     u_a (u_z);
asub #(6) u_as();
zcont     u_zc (u_as);

endmodule
