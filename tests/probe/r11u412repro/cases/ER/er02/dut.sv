// § enumRangedMemberSurelogVal412
typedef enum logic [3:0] {P, Q[3], R=9} t_e;
module top();
	t_e v;
	typedef enum {M[2] = 4, N} m_e;
	m_e w;
endmodule
