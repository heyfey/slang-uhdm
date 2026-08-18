// v99 b2 — every HOME for a ranged `inside`, module + class scope
module mub2 #(parameter int PWB2 = 2) (input logic ckb2, output logic ozb2);
  int    vb21, vb22, vb23, vb24, vb25, vb26;
  logic  gb21, gb22;
  int    qb2 [$];
  int    db2 [];
  int    ab2 [string];
  int    ub2 [4];

  // continuous assign
  assign ozb2 = vb21 inside {[10:20], 33};
  // net decl assign
  wire   nwb2 = vb22 inside {[5:8]};

  // always_comb
  always_comb gb21 = vb23 inside {[1:4], 6};

  // always @(*) with while + ternary
  always @(*) begin
    while (vb24 inside {[2:7]}) vb24 = vb24 + 1;
    gb22 = (vb25 inside {[3:11], 40}) ? 1'b1 : 1'b0;
  end

  // initial
  initial begin
    if (vb26 inside {[0:3]}) vb26 = 9;
  end

  // function
  function automatic int fnb2(int xb2);
    if (xb2 inside {[100:200], 250}) return 1;
    return 0;
  endfunction

  // task
  task automatic tkb2(int yb2);
    if (yb2 inside {[7:9]}) vb21 = yb2;
  endtask

  // with-clause: array locator, reduction, ordering, on queue / dyn / assoc
  int wb21 [$];
  int wb22 [$];
  int wb23 [$];
  int wb24 [$];
  int wb25 [$];
  int wb26;
  int wb27 [$];
  initial begin
    wb21 = qb2.find(itb2) with (itb2 inside {[1:5], 9});
    wb22 = qb2.find_index(itc2) with (itc2 inside {[2:6]});
    wb23 = db2.find_first(itd2) with (itd2 inside {[3:7], 12});
    wb24 = ab2.find_last(ite2) with (ite2 inside {[4:8]});
    wb25 = qb2.unique(itf2) with (itf2 inside {[5:9]});
    wb26 = qb2.sum(itg2) with ((itg2 inside {[6:10]}) ? 1 : 0);
    wb27 = db2.min(ith2) with (ith2 inside {[7:11]});
  end

  // immediate assertion + concurrent property
  always @(posedge ckb2) begin
    assert (vb21 inside {[1:3], 5});
  end
  property prb2;
    @(posedge ckb2) vb22 inside {[2:4]};
  endproperty
  assert property (prb2);
  assert property (@(posedge ckb2) vb23 inside {[8:12], 20});
endmodule

class clb2;
  int    cvb1, cvb2;
  int    cqb1 [$];
  rand int rvb1;
  constraint cnb2 { rvb1 inside {[1:6], 8}; }
  function int mfb2(int pb2);
    if (pb2 inside {[3:5], 7}) return 1;
    return 0;
  endfunction
  extern function int obb2(int pb3);
  function int wcb2();
    int rqb2 [$];
    rqb2 = cqb1.find(icb2) with (icb2 inside {[9:14]});
    return rqb2.size();
  endfunction
endclass

function int clb2::obb2(int pb3);
  if (pb3 inside {[20:30], 44}) return 2;
  return 0;
endfunction

module topb2;
  logic ckt2, o1b2, o2b2, o3b2;
  mub2 #(1) i1b2 (.ckb2(ckt2), .ozb2(o1b2));
  mub2 #(2) i2b2 (.ckb2(ckt2), .ozb2(o2b2));
  mub2 #(3) i3b2 (.ckb2(ckt2), .ozb2(o3b2));
endmodule
