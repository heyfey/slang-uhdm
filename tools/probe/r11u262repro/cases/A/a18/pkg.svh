`define MK_ENUM(n) typedef enum logic [1:0] { n``_A, n``_B, n``_C } n``_t;
package ip;
  `MK_ENUM(H)
endpackage
