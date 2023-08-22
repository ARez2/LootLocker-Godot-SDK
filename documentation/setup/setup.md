# Setup the LootLocker SDK
## setup your own LockLocker account

In order to fully benefit from this SDK, you've to create a **_LootLocker_ account** first, it's free, easy and pretty quick.

Go to [LootLocker website](https://lootlocker.com/) and click on the big button on the top right corner
![LL-create-account](https://github.com/ARez2/LootLocker-Godot-SDK/assets/136735040/cb741631-5670-4f44-9080-926387a30007)


Enter you email address and a password, then follow the account creation process.
Then, a good place to start is the [documentation](https://docs.lootlocker.com/the-basics/readme), it's worth reading it to understand the basics and be able to build on strong foundations.

## Create a game

Create a game, give it the name you want, "_SDK-test_" could be a good one for our purpose here.

## Get keys

The **keys** will be use to be able to interact with _LootLocker_ system using the SDK.
Click on settings icon, then keys as displayed on the picture below

![LL-keys2](https://github.com/ARez2/LootLocker-Godot-SDK/assets/136735040/08627d7b-d083-4787-9323-a852e65d4232)
(note these keys are **mine**, and I don't mind these as this is just a dummy game created for the purpose of this documentation, you'll see different values for you own keys to use later)

I willingly don't go deep into the details as the official documentation cover already everything so, again, use it.

For now, only the API key is use by the SDK. So we're ready to dive into the matter and actually setup the SDK, let'go !

## Setup the SDK

* Create a file name "_.sdk_data_password_" in your project user files directory (you do need to run your project at least once before, so it need even a dummy scene which does nothing yet, or create the folder yourself, see _Godot_ documention for files location on your system). On _windows_, directory is "`C:\Users\<username>\AppData\Roaming\Godot\app_userdata\LootLocker-Godot-SDK`"
("_LootLocker-Godot-SDK_" is the Godot project, to replace with the actual name of your project if it's not the SDK project itself)

* Put the password you want to use to protect your _LootLocker_'s keys in clear text (the password)
  
	`example: thisISmySECRETpassword`

**no space**, **no tab**, **no line return**, **no anything** except the password alone, all characters there will be considered as the password.

* Open the scene "_sdk_init-save_", click on script icon of the lonely node named "_test-SDKinit_"
**replace all keys** values by your own as well as game version.

Note: in the current release (early alpha) of the SDK, I do not use server and domain keys yet.

* Run the scene, result of _save_sdk_data_ function should be **0** and nothing more printed in output.

* Just to check everything's fine, you can run the "_sdk_init-load_" scene which will print keys values you've entered previsouly. If it doesn't work, there is an issue somewhere which needed to be fixed before moving forward.
