:: admin public key
if exist C:\Users\admin\authorized_keys (
  if NOT exist C:\Users\admin\.ssh (
    mkdir C:\Users\admin\.ssh
  )
  copy C:\Users\admin\authorized_keys C:\Users\admin\.ssh\authorized_keys
) 
