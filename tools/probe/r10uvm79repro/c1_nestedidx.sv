class item;
  int sequence_ptr;
endclass

class seqr;
  item   arb_sequence_q[$];
  int    avail_sequences[$];
  int    marr[4];
  int    midx[4];
  item   iarr[4];

  function int is_blocked(int p); return 0; endfunction

  function int m_choose_next_request();
    int i;
    // c1: THE HEAD SHAPE — nested bit_select as index, member tail, queue base
    if (is_blocked(arb_sequence_q[avail_sequences[i]].sequence_ptr) != 0) begin
      i = 1;
    end
    // c2: same but fixed arrays (not queues)
    i = iarr[midx[i]].sequence_ptr;
    // c3: plain variable index (control — known-good shape)
    i = iarr[i].sequence_ptr;
    // c4: nested select as index, NO member tail
    i = marr[midx[i]];
    // c5: depth-3 nesting
    i = marr[midx[midx[i]]];
    return i;
  endfunction
endclass

module top;
  typedef struct { int sequence_ptr; } st;
  st  marr2[4];
  int midx2[4];
  int j;
  // c6: MODULE scope, nested select as index with member tail
  initial begin
    j = marr2[midx2[j]].sequence_ptr;
    // c7: module scope, no member tail
    j = midx2[midx2[j]];
  end
endmodule
