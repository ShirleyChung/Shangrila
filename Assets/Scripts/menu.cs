using UnityEngine;
using System.Collections;

public class menu : MonoBehaviour {

	private bool canContinue = true;
	
	void Start () {
		string checkLevelName = PlayerPrefs.GetString("savedLevel");
		if(checkLevelName == null || checkLevelName == ""){
			canContinue = false;
		}
	}
	//按鈕內sendMessageUp輸入startGame後按下按鈕會到Level1
	void startGame () {
		PlayerPrefs.DeleteAll();
		Application.LoadLevel("level1");
	}

	//按鈕內sendMessageUp輸入continueGame後按下按鈕會到儲存的關卡
	void continueGame () {
		if(canContinue){
			string levelName = PlayerPrefs.GetString("savedLevel");
			Application.LoadLevel(levelName);
		}
	}
}
