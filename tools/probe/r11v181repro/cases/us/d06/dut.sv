// § bigDecUnderscoreDropped181v (v11u181: a bare decimal wider than 64 bits written with separators)
module top(output logic [79:0] y);
  initial y = 1_000_000_000_000_000_000_000;
endmodule
