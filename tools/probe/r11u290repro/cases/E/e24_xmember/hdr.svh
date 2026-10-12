// § caUnitEnumUnresolvedShares290
`ifndef HDR_SVH
`define HDR_SVH
localparam logic ONE = 1'b1;
typedef enum logic {
    E_RD = 1'b0,
    E_WR = ONE,
    E_ERR = 'x
} cmd_e;
`endif
