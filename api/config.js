// Vercel 서버리스 함수: 환경변수에서 Supabase 설정을 반환
export default function handler(req, res) {
  res.setHeader('Content-Type', 'application/json');
  res.status(200).json({
    url: process.env.SUPABASE_URL || '',
    key: process.env.SUPABASE_KEY || ''
  });
}
