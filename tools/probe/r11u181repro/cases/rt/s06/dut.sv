// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — the $root path baseline copied from tools/probe/r11u173verify cases/hw/w09_root_path_noblank_ctl (its law there: pass 157/167)
module top (input logic a, output logic y);
  logic s;
  assign s = a;
  assign y = $root.top.s;
endmodule
