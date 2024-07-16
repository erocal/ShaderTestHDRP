using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{

    #region -- 資源參考區 --

    public float moveSpeed = 5f;

    #endregion

    #region -- 變數參考區 --

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{
		
	}

    void Update()
    {
        // 獲取輸入
        float moveX = Input.GetAxis("Horizontal");
        float moveY = Input.GetAxis("Vertical");

        // 計算移動
        Vector3 movement = new Vector3(moveX, 0, moveY) * moveSpeed * Time.deltaTime;

        // 應用移動
        transform.Translate(movement, Space.World);
    }

    #endregion

    #region -- 方法參考區 --

    #endregion

}
