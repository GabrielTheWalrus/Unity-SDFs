using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDF_CONFIG : MonoBehaviour
{

    public int Qtd_Objects;
    public float[] Object_Types;
    public Vector4[] Positions;
    // public Vector4[] Translations; 
    public Vector4[] Rotations; 
    public Vector4[] Scales;
    public Vector4[] Colors;
    public Vector4[] Operations;
    public Material material;

    // Start is called before the first frame update
    void Start() {}

    // Update is called once per frame
    void Update()
    {
        material.SetFloat("_QtdObj", Qtd_Objects);
        material.SetFloatArray("_ObjectTypes", Object_Types);
        material.SetVectorArray("_Positions", Positions);
        // material.SetVectorArray("_Translations", Translations);
        material.SetVectorArray("_Rotations", Rotations);
        material.SetVectorArray("_Scales", Scales);
        material.SetVectorArray("_Colors", Colors);
        material.SetVectorArray("_Operations", Operations);
    }
}
