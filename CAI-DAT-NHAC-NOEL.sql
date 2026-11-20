-- Chạy một lần trong Supabase SQL Editor để bật tính năng Admin thay nhạc.
-- Website hiện dùng bảng public.booking_settings và cột id = true.

alter table public.booking_settings
  add column if not exists music_url text;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('site-assets', 'site-assets', true, 26214400,
        array['audio/mpeg','audio/mp3','audio/wav','audio/ogg'])
on conflict (id) do update set
  public = true,
  file_size_limit = 26214400,
  allowed_mime_types = excluded.allowed_mime_types;

-- Khách được tải nhạc công khai để phát trên website.
drop policy if exists "Public can read Christmas music" on storage.objects;
create policy "Public can read Christmas music"
  on storage.objects for select
  to public
  using (bucket_id = 'site-assets');

-- Chỉ tài khoản được hàm is_admin() xác nhận mới được tải / thay / xóa nhạc.
drop policy if exists "Admins upload Christmas music" on storage.objects;
create policy "Admins upload Christmas music"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'site-assets' and public.is_admin());

drop policy if exists "Admins update Christmas music" on storage.objects;
create policy "Admins update Christmas music"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'site-assets' and public.is_admin())
  with check (bucket_id = 'site-assets' and public.is_admin());

drop policy if exists "Admins delete Christmas music" on storage.objects;
create policy "Admins delete Christmas music"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'site-assets' and public.is_admin());
