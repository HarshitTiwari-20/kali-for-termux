# Step 1: Update Termux


```
pkg update && pkg upgrade -y
```

# Step 2: Install required packages

```
pkg install proot wget tar -y
```

# Step 3: Download and run the script

```
wget https://raw.githubusercontent.com/Neo-Oli/termux-ubuntu/master/ubuntu.sh -O install-kali.sh
```

#chmod


```
chmod +x install-kali.sh
```



```
./install-kali.sh
```

# or ./install-kali.sh -y   → auto-yes

# Step 4: Launch Kali

```
./start-kali.sh
```
