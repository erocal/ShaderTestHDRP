using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{

    #region -- 資源參考區 --

    public float moveSpeed = 5f;

    public float rotationSpeed = 100f;
    public float verticalRotationSpeed = 100f;

    private float verticalRotationLimit = 80f;
    private float verticalRotation = 0f;

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
        Vector3 movement = (transform.forward * moveY + transform.right * moveX) * moveSpeed * Time.deltaTime;

        movement.y = 0f;

        // 應用移動
        transform.Translate(movement, Space.World);

        Rotation();
    }

    #endregion

    #region -- 方法參考區 --

    private void Rotation()
    {
        // 鍵盤控制
        float rotation = 0f;
        if (Input.GetKey(KeyCode.Q))
        {
            rotation = -rotationSpeed * Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.E))
        {
            rotation = rotationSpeed * Time.deltaTime;
        }

        // 滑鼠控制水平旋轉
        float mouseX = Input.GetAxis("Mouse X") * rotationSpeed * Time.deltaTime;

        // 滑鼠控制垂直旋轉
        float mouseY = Input.GetAxis("Mouse Y") * verticalRotationSpeed * Time.deltaTime;
        verticalRotation -= mouseY;
        verticalRotation = Mathf.Clamp(verticalRotation, -verticalRotationLimit, verticalRotationLimit);

        // 應用旋轉
        transform.Rotate(Vector3.up, rotation + mouseX, Space.World);
        transform.localEulerAngles = new Vector3(verticalRotation, transform.localEulerAngles.y, 0f);

    }

    #endregion

}
