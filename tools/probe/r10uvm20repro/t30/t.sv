// r10uvm20 t30 — foreach LOOP-VARIABLE class matrix.
// {queue, dynamic, fixed, assoc} x {int, string, class handle, struct},
// each in four owner contexts, so `getSimpleVarFromTypespec applied to what?`
// can be read straight off the golden pair.
typedef struct packed { int a; bit b; } st_t;

class Cel;
  int x;
endclass

class Cbox;
  int p_q_int[$];
  string p_q_str[$];
  Cel p_q_cls[$];
  st_t p_q_stx[$];
  int p_d_int[];
  string p_d_str[];
  Cel p_d_cls[];
  st_t p_d_stx[];
  int p_f_int[4];
  string p_f_str[4];
  Cel p_f_cls[4];
  st_t p_f_stx[4];
  int p_a_int[string];
  string p_a_str[string];
  Cel p_a_cls[string];
  st_t p_a_stx[string];

  function void mloc();
    int l_q_int[$];
    string l_q_str[$];
    Cel l_q_cls[$];
    st_t l_q_stx[$];
    int l_d_int[];
    string l_d_str[];
    Cel l_d_cls[];
    st_t l_d_stx[];
    int l_f_int[4];
    string l_f_str[4];
    Cel l_f_cls[4];
    st_t l_f_stx[4];
    int l_a_int[string];
    string l_a_str[string];
    Cel l_a_cls[string];
    st_t l_a_stx[string];
    foreach (l_q_int[i_l_q_int]) l_q_int[i_l_q_int] = l_q_int[i_l_q_int];
    foreach (l_q_str[i_l_q_str]) l_q_str[i_l_q_str] = l_q_str[i_l_q_str];
    foreach (l_q_cls[i_l_q_cls]) l_q_cls[i_l_q_cls] = l_q_cls[i_l_q_cls];
    foreach (l_q_stx[i_l_q_stx]) l_q_stx[i_l_q_stx] = l_q_stx[i_l_q_stx];
    foreach (l_d_int[i_l_d_int]) l_d_int[i_l_d_int] = l_d_int[i_l_d_int];
    foreach (l_d_str[i_l_d_str]) l_d_str[i_l_d_str] = l_d_str[i_l_d_str];
    foreach (l_d_cls[i_l_d_cls]) l_d_cls[i_l_d_cls] = l_d_cls[i_l_d_cls];
    foreach (l_d_stx[i_l_d_stx]) l_d_stx[i_l_d_stx] = l_d_stx[i_l_d_stx];
    foreach (l_f_int[i_l_f_int]) l_f_int[i_l_f_int] = l_f_int[i_l_f_int];
    foreach (l_f_str[i_l_f_str]) l_f_str[i_l_f_str] = l_f_str[i_l_f_str];
    foreach (l_f_cls[i_l_f_cls]) l_f_cls[i_l_f_cls] = l_f_cls[i_l_f_cls];
    foreach (l_f_stx[i_l_f_stx]) l_f_stx[i_l_f_stx] = l_f_stx[i_l_f_stx];
    foreach (l_a_int[i_l_a_int]) l_a_int[i_l_a_int] = l_a_int[i_l_a_int];
    foreach (l_a_str[i_l_a_str]) l_a_str[i_l_a_str] = l_a_str[i_l_a_str];
    foreach (l_a_cls[i_l_a_cls]) l_a_cls[i_l_a_cls] = l_a_cls[i_l_a_cls];
    foreach (l_a_stx[i_l_a_stx]) l_a_stx[i_l_a_stx] = l_a_stx[i_l_a_stx];
  endfunction

  function void mprop();
    foreach (p_q_int[i_p_q_int]) p_q_int[i_p_q_int] = p_q_int[i_p_q_int];
    foreach (p_q_str[i_p_q_str]) p_q_str[i_p_q_str] = p_q_str[i_p_q_str];
    foreach (p_q_cls[i_p_q_cls]) p_q_cls[i_p_q_cls] = p_q_cls[i_p_q_cls];
    foreach (p_q_stx[i_p_q_stx]) p_q_stx[i_p_q_stx] = p_q_stx[i_p_q_stx];
    foreach (p_d_int[i_p_d_int]) p_d_int[i_p_d_int] = p_d_int[i_p_d_int];
    foreach (p_d_str[i_p_d_str]) p_d_str[i_p_d_str] = p_d_str[i_p_d_str];
    foreach (p_d_cls[i_p_d_cls]) p_d_cls[i_p_d_cls] = p_d_cls[i_p_d_cls];
    foreach (p_d_stx[i_p_d_stx]) p_d_stx[i_p_d_stx] = p_d_stx[i_p_d_stx];
    foreach (p_f_int[i_p_f_int]) p_f_int[i_p_f_int] = p_f_int[i_p_f_int];
    foreach (p_f_str[i_p_f_str]) p_f_str[i_p_f_str] = p_f_str[i_p_f_str];
    foreach (p_f_cls[i_p_f_cls]) p_f_cls[i_p_f_cls] = p_f_cls[i_p_f_cls];
    foreach (p_f_stx[i_p_f_stx]) p_f_stx[i_p_f_stx] = p_f_stx[i_p_f_stx];
    foreach (p_a_int[i_p_a_int]) p_a_int[i_p_a_int] = p_a_int[i_p_a_int];
    foreach (p_a_str[i_p_a_str]) p_a_str[i_p_a_str] = p_a_str[i_p_a_str];
    foreach (p_a_cls[i_p_a_cls]) p_a_cls[i_p_a_cls] = p_a_cls[i_p_a_cls];
    foreach (p_a_stx[i_p_a_stx]) p_a_stx[i_p_a_stx] = p_a_stx[i_p_a_stx];
  endfunction
endclass

module top;
  int m_q_int[$];
  string m_q_str[$];
  Cel m_q_cls[$];
  st_t m_q_stx[$];
  int m_d_int[];
  string m_d_str[];
  Cel m_d_cls[];
  st_t m_d_stx[];
  int m_f_int[4];
  string m_f_str[4];
  Cel m_f_cls[4];
  st_t m_f_stx[4];
  int m_a_int[string];
  string m_a_str[string];
  Cel m_a_cls[string];
  st_t m_a_stx[string];

  task tloc();
    int t_q_int[$];
    string t_q_str[$];
    Cel t_q_cls[$];
    st_t t_q_stx[$];
    int t_d_int[];
    string t_d_str[];
    Cel t_d_cls[];
    st_t t_d_stx[];
    int t_f_int[4];
    string t_f_str[4];
    Cel t_f_cls[4];
    st_t t_f_stx[4];
    int t_a_int[string];
    string t_a_str[string];
    Cel t_a_cls[string];
    st_t t_a_stx[string];
    foreach (t_q_int[i_t_q_int]) t_q_int[i_t_q_int] = t_q_int[i_t_q_int];
    foreach (t_q_str[i_t_q_str]) t_q_str[i_t_q_str] = t_q_str[i_t_q_str];
    foreach (t_q_cls[i_t_q_cls]) t_q_cls[i_t_q_cls] = t_q_cls[i_t_q_cls];
    foreach (t_q_stx[i_t_q_stx]) t_q_stx[i_t_q_stx] = t_q_stx[i_t_q_stx];
    foreach (t_d_int[i_t_d_int]) t_d_int[i_t_d_int] = t_d_int[i_t_d_int];
    foreach (t_d_str[i_t_d_str]) t_d_str[i_t_d_str] = t_d_str[i_t_d_str];
    foreach (t_d_cls[i_t_d_cls]) t_d_cls[i_t_d_cls] = t_d_cls[i_t_d_cls];
    foreach (t_d_stx[i_t_d_stx]) t_d_stx[i_t_d_stx] = t_d_stx[i_t_d_stx];
    foreach (t_f_int[i_t_f_int]) t_f_int[i_t_f_int] = t_f_int[i_t_f_int];
    foreach (t_f_str[i_t_f_str]) t_f_str[i_t_f_str] = t_f_str[i_t_f_str];
    foreach (t_f_cls[i_t_f_cls]) t_f_cls[i_t_f_cls] = t_f_cls[i_t_f_cls];
    foreach (t_f_stx[i_t_f_stx]) t_f_stx[i_t_f_stx] = t_f_stx[i_t_f_stx];
    foreach (t_a_int[i_t_a_int]) t_a_int[i_t_a_int] = t_a_int[i_t_a_int];
    foreach (t_a_str[i_t_a_str]) t_a_str[i_t_a_str] = t_a_str[i_t_a_str];
    foreach (t_a_cls[i_t_a_cls]) t_a_cls[i_t_a_cls] = t_a_cls[i_t_a_cls];
    foreach (t_a_stx[i_t_a_stx]) t_a_stx[i_t_a_stx] = t_a_stx[i_t_a_stx];
  endtask

  task tmod();
    foreach (m_q_int[i_m_q_int]) m_q_int[i_m_q_int] = m_q_int[i_m_q_int];
    foreach (m_q_str[i_m_q_str]) m_q_str[i_m_q_str] = m_q_str[i_m_q_str];
    foreach (m_q_cls[i_m_q_cls]) m_q_cls[i_m_q_cls] = m_q_cls[i_m_q_cls];
    foreach (m_q_stx[i_m_q_stx]) m_q_stx[i_m_q_stx] = m_q_stx[i_m_q_stx];
    foreach (m_d_int[i_m_d_int]) m_d_int[i_m_d_int] = m_d_int[i_m_d_int];
    foreach (m_d_str[i_m_d_str]) m_d_str[i_m_d_str] = m_d_str[i_m_d_str];
    foreach (m_d_cls[i_m_d_cls]) m_d_cls[i_m_d_cls] = m_d_cls[i_m_d_cls];
    foreach (m_d_stx[i_m_d_stx]) m_d_stx[i_m_d_stx] = m_d_stx[i_m_d_stx];
    foreach (m_f_int[i_m_f_int]) m_f_int[i_m_f_int] = m_f_int[i_m_f_int];
    foreach (m_f_str[i_m_f_str]) m_f_str[i_m_f_str] = m_f_str[i_m_f_str];
    foreach (m_f_cls[i_m_f_cls]) m_f_cls[i_m_f_cls] = m_f_cls[i_m_f_cls];
    foreach (m_f_stx[i_m_f_stx]) m_f_stx[i_m_f_stx] = m_f_stx[i_m_f_stx];
    foreach (m_a_int[i_m_a_int]) m_a_int[i_m_a_int] = m_a_int[i_m_a_int];
    foreach (m_a_str[i_m_a_str]) m_a_str[i_m_a_str] = m_a_str[i_m_a_str];
    foreach (m_a_cls[i_m_a_cls]) m_a_cls[i_m_a_cls] = m_a_cls[i_m_a_cls];
    foreach (m_a_stx[i_m_a_stx]) m_a_stx[i_m_a_stx] = m_a_stx[i_m_a_stx];
  endtask
endmodule
