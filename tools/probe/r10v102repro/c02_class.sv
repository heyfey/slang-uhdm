package c02p;
  class C02 #(parameter CB = 'b101,
              parameter int CTB = 'b101,
              parameter [7:0] CRB = 'b101);
    parameter CIB = 'h1a;
    localparam CIL = 'o17;
  endclass
  typedef C02#(.CB('h2b)) C02s;
  class D02;
    localparam DL = 'b101;
  endclass
endpackage
