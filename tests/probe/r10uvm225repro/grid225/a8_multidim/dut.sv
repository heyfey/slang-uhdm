// r10uvm225 arm a8_multidim — MIXED unpacked chains: how many vpiRange does
// the array_net carry, and in what order, when the chain mixes kinds?
typedef logic [7:0] tvd225_t;

interface if225_md();
  typedef int tid225_t;
  tvd225_t d_ff225   [1:0][3];
  tvd225_t d_fd225   [1:0][];
  tvd225_t d_df225   [][1:0];
  tvd225_t d_fq225   [1:0][$];
  tvd225_t d_qf225   [$][1:0];
  tvd225_t d_fa225   [1:0][string];
  tvd225_t d_af225   [string][1:0];
  tvd225_t d_aa225   [string][int];
  tvd225_t d_an225   [string][tid225_t];
  tvd225_t d_na225   [tid225_t][string];
  tvd225_t d_ad225   [string][];
  tvd225_t d_ddd225  [][][];
  tvd225_t d_fff225  [1:0][2][3];
endinterface

module top225_md(); endmodule
