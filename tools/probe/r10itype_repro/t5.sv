interface aif #(
  parameter int PA = 1
);
  logic w;
endinterface

module mmid (
  aif  p
);
  logic mz;
endmodule

module top();

aif #(5) u_a();
mmid     u_m (u_a);

endmodule
