// § patLitFormFileAtRef256 (struct-pattern member values read from a package in another file (Earlgrey rv_dm DebugHartInfo))
module top(output logic [19:0] o);
  localparam dm::hartinfo_t DebugHartInfo = '{
    zero1:      '0,
    datasize:   dm::DataCount,
    dataaddr:   dm::DataAddr
  };
  assign o = DebugHartInfo;
endmodule
