// decode case (no law of this pass): the pipelined_get_put head chain, see README

package mbus_types_pkg;

typedef enum {IDLE, SINGLE, BURST4, BURST8} mbus_opcode_e;
typedef enum logic[2:0] {NULL, READ_VALID, READ_ADDR_ERROR, READ_UNINIT, WRITE_COMPLETE, WRITE_ADDR_ERROR, ADDR_ERROR} mbus_resp_e;

// Mbus sequence item struct
typedef struct packed {
  // From the master to the slave
  logic[31:0] MADDR;
  logic[31:0] MWDATA;
  logic MREAD;
  mbus_opcode_e MOPCODE;

  // Driven by the slave to the master
  mbus_resp_e MRESP;
  logic[31:0] MRDATA;
} mbus_seq_item_s;

parameter int MBUS_SEQ_ITEM_NUM_BITS  = $bits(mbus_seq_item_s);
parameter int MBUS_SEQ_ITEM_NUM_BYTES = (MBUS_SEQ_ITEM_NUM_BITS+7)/8;

typedef bit [MBUS_SEQ_ITEM_NUM_BITS-1:0] mbus_seq_item_vector_t;

endpackage: mbus_types_pkg
module top;
endmodule
