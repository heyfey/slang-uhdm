interface zzif #(
  parameter int PA = 1
);
  logic w;
endinterface

module amid (
  zzif  p
);
  logic mz;
endmodule

module top();

zzif #(5) u_a();
amid      u_m (u_a);

endmodule
