using UnityEngine;
using System.Collections;

public class mouseButton : MonoBehaviour {

	//設定一個輸入欄位告知按鈕的作用
	public string sendMessageUp = "";
	public bool standalone = true;
	
	
	private bool over = false;
	
	void Start () {
		if(!standalone){
			gameObject.SetActive(false);
		}
		
	}
	//點擊按鈕在按鈕上放開滑鼠代表是點擊
	void OnMouseEnter () {
		over = true;
	}
	//點擊按鈕在按鈕外放開滑鼠代表不是點擊
	void OnMouseExit () {
		over = false;
	}
	
	void Update () {
		if(Input.GetMouseButtonUp(0)){
			if(over){
				SendMessageUpwards(sendMessageUp, SendMessageOptions.DontRequireReceiver);
			}
		}
	}
}
